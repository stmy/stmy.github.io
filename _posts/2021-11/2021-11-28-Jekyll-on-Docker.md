---
layout: post
title:  "Docker 上で Jekyll を動かす"
tags: Jekyll Docker VSCode
---

5 年前は WSL 上に Ruby 環境を構築して Jekyll を動かしていたみたいですが、もっとモダンに Docker 上で動かすようにしてみます。

いろいろインストールして開発マシンの環境を汚さなくていいので精神的にもいいです。

<!--more-->

まずは Dockerfile。ベースとして Ruby の公式リポジトリにあるイメージを使用します。（ここでは好みで Alpine イメージを使用。）

```Dockerfile
FROM ruby:alpine

# Native extensions のビルドに必要なパッケージ達
RUN apk add make gcc g++ musl-dev openssl-dev

# Jekyll 実行環境の準備
RUN mkdir /jekyll
WORKDIR /jekyll
ADD ./Gemfile ./Gemfile.lock ./
RUN bundler install

# 作業ディレクトリ準備
RUN mkdir /work
WORKDIR /work
```

動くか確認。

```
> docker build -t jekyll .
> docker run -v "${PWD}:/work" -p "4000:4000" -it jekyll bundle exec jekyll serve --watch --port 4000 --host 0.0.0.0
Configuration file: /work/_config.yml
            Source: /work
       Destination: /work/_site
 Incremental build: disabled. Enable with --incremental
      Generating...
                    done in 0.512 seconds.
                    Auto-regeneration may not work on some Windows versions.
                    Please see: https://github.com/Microsoft/BashOnWindows/issues/216
                    If it does not work, please upgrade Bash on Windows or run Jekyll with --no-watch.
 Auto-regeneration: enabled for '/work'
    Server address: http://0.0.0.0:4000/
  Server running... press ctrl-c to stop.
```

よさそうですね。

ちなみに `--host 0.0.0.0` をつけないと、ローカルループバックインタフェース上にバインドされるので、外側からアクセスできなくなります。30 分くらいハマってました。

あとは使うときに上記コマンドを動かせばいいのですが、VSCode 派の自分は面倒なのでタスクを書きます。

```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Start Server",
            "type": "shell",
            "command": "docker run -v ${PWD}:/work -p 4000:4000 -it jekyll bundle exec jekyll serve --watch --port 4000 --host 0.0.0.0",
            "isBackground": true,
            "problemMatcher": [
                {
                    "owner": "custom",
                    "pattern":[
                        {
                            "regexp": "^$",
                            "file": 1,
                            "location": 2,
                            "message": 3
                        }
                    ],
                    "background": {
                        "activeOnStart": true,
                        "beginsPattern": ".",
                        "endsPattern": "Server running\\.\\.\\. press ctrl-c to stop\\."
                    }
                }
            ]
        },
        {
            "label": "Open With Browser",
            "type": "shell",
            "command": "chrome",
            "windows": {
                "command": "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe",
                "args": [
                    "-incognito",
                    "http://localhost:4000"
                ]
            },
            "dependsOn": [
                "Start Server"
            ]
        }
    ]
}
```

あとは `Ctrl+P` > `task Open With Browser` で即座にブラウザプレビューができるようになります。便利。