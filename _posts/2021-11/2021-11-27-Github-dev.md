---
layout: post
title:  "5 年ぶりに更新"
tags: etc
---

5 年経っているけど更新できるだろうか？

GitHub.dev から更新してみる。

<!-- more -->

【追記】

ちゃんと動いてるっぽいですね。すばらしい。

https://github.dev/stmy/stmy.github.io を PWA としてデスクトップショートカット登録してみましたが、何故か起動すると https://github.dev/github/dev に飛ばされてしまう模様。

【さらに追記】

なんかコードのとこが派手に壊れてますね...。

```rust:main.rs
use std::fs::File;
use std::io::Write;
use std::io::Read;
use std::net::TcpStream;
use std::net::TcpListener;

fn main() {
    
    let listener = TcpListener::bind("127.0.0.1:7878").unwrap();

    for stream in listener.incoming() {
        let stream = stream.unwrap();

        handle_connection(stream);
    }

}

fn handle_connection(mut stream: TcpStream) {
    let mut buffer = [0; 1024];

    stream.read(&mut buffer).unwrap();

    let mut file = File::open("src/hello.html").unwrap();
    let mut contents = String::new();
    file.read_to_string(&mut contents).unwrap();

    let response = format!("HTTP/1.1 200 OK\r\n\r\n{}", contents);

    stream.write(response.as_bytes()).unwrap();
    stream.flush().unwrap();

    //println!("Request: {}", String::from_utf8_lossy(&buffer));
}
```