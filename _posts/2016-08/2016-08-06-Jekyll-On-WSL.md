---
layout: post
title:  "Jekyll を Windows Subsystem for Linux 上で動かす"
tags: WSL Jekyll Memo
---

ちょっとつまずくポイントがあったのでメモ。

<!--more-->

Windows Subsystem for Linux (WSL) がインストールされている状態からスタート。

コンソール上での日本語表示が怪しい（2016/8/6 現在）ので、最初に英語表示に戻しておく。

```
sudo update-locale LANG="en_US.utf8" LANGUAGE="en_US"
```

シェルを再起動後、Ruby 環境をインストール。

```
$ sudo apt-get update
$ sudo apt-get install git autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
$ echo 'PATH="$PATH:$HOME/.rbenv/bin"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
$ source ~/.bashrc
$ rbenv install 2.3.1
$ rbenv global 2.3.1
$ rbenv shell 2.3.1
```

Bundler をインストールし、

```
$ gem install bundler
```

Bundler のキャッシュディレクトリのパーミッションを変更。（参考: [Issue #4599]( https://github.com/bundler/bundler/issues/4599#issuecomment-237567988)）

```
$ find ~/.bundle/cache -type d -exec chmod 0755 {} +
```

あとは Jekyll サイトのディレクトリに行って、Jekyll を実行。

```
$ cd /path/to/blog
$ bundle exec jekyll serve --watch --force_polling
```

[WSL が inotify をサポートしていないらしく](https://wpdev.uservoice.com/forums/266908-command-prompt-console-bash-on-ubuntu-on-windo/suggestions/13469097-support-for-filesystem-watchers-like-inotify)（2016/8/6 現在）、`--force_polling` オプションを使う必要がある模様。

あとはブラウザで [http://127.0.0.1:4000/](http://127.0.0.1:4000/) にアクセスすればサイトが見られるはず。
