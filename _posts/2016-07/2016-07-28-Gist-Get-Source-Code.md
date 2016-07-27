---
layout: post
title:  Gistの動的取得
tags: Gist JavaScript CSS
---

Gist を張り付ける際に Gist の CSS が読み込まれてほしくない人向け情報。

<!--more-->

# API を使う方法

`https://api.github.com/gists/:id` に GET を投げると gist の内容を返してくれる。

<script async src="https://jsfiddle.net/0ke95not/1/embed/js,html,result/"></script>

この方法だと、プレーンテキストでの取得になるので、コードハイライトが必要なら Highlight.js とかを使う必要がある。

# インラインフレームを使う方法

`iframe` 要素の中で Gist Embed のスクリプトを実行して、生成された HTML だけを取ってくる方法。

<script async src="https://jsfiddle.net/v5op7ka4/embed/js,html,result/"></script>

あとは対応する CSS を書けばいいだけ。

クラス名は [GitHub の中の人が linguist リポジトリのコメントで](https://github.com/github/linguist/issues/1822#issuecomment-66510457) 、linguist のスコープ名との対応表を出してくれているので、それを参考にして色を付けたりすれば良さそう。

# スタイルを上書きしたいだけなら…

優先順位を上げればいいだけなので、

<script async src="https://jsfiddle.net/tjnjfxy2/embed/html,css,result/"></script>

こんな感じで親になる要素を先頭にくっつければいいだけ。
