---
layout: post
title:  "Spring Boot の application.properties で Docker の Secret を使いたい！"
tags:   Java "Spring Boot" Docker
---

データベースのパスワードを `application.properties` に生で書くのは抵抗があるので、Secret の値を使えるようにできないかなと思い調べてみました。

結論から言うと、できます。

<!--more-->

やりかたとしては、独自のプロパティソースを使う感じにするのが良さそうです。

ググるとネット上にもちらほら情報が転がっていますが、以下のように `EnvironmentPostProcessor` インタフェースを実装して登録することになります。

```java
package jp.stmy.myapp.env;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.boot.logging.DeferredLog;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;
import org.springframework.stereotype.Component;

@Order(Ordered.LOWEST_PRECEDENCE)
public class SecretVariableProcessor 
    implements EnvironmentPostProcessor, 
               ApplicationListener<ApplicationEvent> {

    private static final DeferredLog log = new DeferredLog();

    public final String SECRET_PREFIX = "secret--";
    public final String SECRET_DIR = "/run/secrets";
    
    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        
        final var secretDir = Path.of(SECRET_DIR).toFile();

        // Do nothing if secrets directory is not exists or not a directory
        if (!secretDir.exists() || !secretDir.isDirectory()) {
            return;
        }

        // Enumerate secret files
        final var secretFiles = Stream.of(secretDir.listFiles())
            .filter(file -> file.isFile())
            .collect(Collectors.toList());

        // Create key-value map of secrets
        final var secretMap = new HashMap<String, Object>();
        secretFiles.forEach(file -> {
            try {
                final var key = SECRET_PREFIX + file.getName();
                final var value = Files.readString(file.toPath());
                secretMap.put(key, value);
                log.info("Secret value added: " + key);
            } catch (IOException e) {
                log.error(e.getMessage(), e);
                System.out.println(e.getMessage());
            }
        });
        
        // Create secret property source, and add it to the environment
        final var propertySource = new MapPropertySource("secrets", secretMap);
        environment.getPropertySources().addLast(propertySource);
    }

    @Override
    public void onApplicationEvent(ApplicationEvent event) {
        log.replayTo(SecretVariableProcessor.class);
    }
    
}
```

やってることとしては非常に単純で、 `SECRET_DIR` 配下のファイルについて、`secret--ファイル名` をキー、ファイルの内容を値としたプロパティソースを最低優先度で追加してあげているだけです。

`SECRET_DIR` の内容は本来設定ファイルに書けるようにすべきですが、完全に手を抜いています。

このクラスは完全に初期化する前に実行されるため、 `ApplicationListener<ApplicationEvent>` を実装して、ロギングが遅延実行されるようにしています。

Spring への登録は `src/main/resources/META-INF/spring.factories` に以下のように行います。

```properties
org.springframework.boot.env.EnvironmentPostProcessor=jp.stmy.myapp.env.SecretVariableProcessor
```

実際に以下のような感じで使います。

```properties
spring.datasource.url=jdbc:postgresql://db:5432/${secret--postgres_db}
spring.datasource.username=${secret--postgres_user}
spring.datasource.password=${secret--postgres_passwd}
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
```

パスワードやユーザ名が設定ファイルから消えました！

なかなかいい感じですね。