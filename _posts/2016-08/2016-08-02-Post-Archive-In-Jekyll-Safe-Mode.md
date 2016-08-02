---
layout: post
title:  Github Pages の Jekyll でアーカイブ機能を実装する
tags: Github-Pages Jekyll
---

Github Pages の Jekyll はセーフモードで動作しているため、カスタムタグで細かい処理を書くことができません。

そのため、表題のようなことをするときは、いろいろ工夫してやる必要があります。

<!--more-->

# タグ別アーカイブ

## 件数付きタグリスト

タグは `site.tags` で取得でき、列挙するだけなら簡単なのですが、その件数と名前で並び替えをしようとすると割と面倒なことになります。
ここでは、件数の降順 → タグ名の昇順の順でソートします。

まず、タグ名と件数をセパレータで結合した文字列のリストを作成し、降順でソートします。

{% raw %}
```liquid
{% assign separator = "{3aacbed8-6af0-42f4-8338-6bcfa91cd2d7}" %}
{% assign taglist_alpha_reversed = "" | split: "" %}
{% for t in site.tags %}
    {% capture item %}{{ t[0] }}{{ separator }}{{ t[1].size }}{% endcapture %}
    {% assign taglist_alpha_reversed = taglist_alpha_reversed | push: item %}
{% endfor %}
{% assign taglist_alpha_reversed = taglist_alpha_reversed | sort | reverse %}
```
{% endraw %}

※セパレータはタグに含まれなさそうな文字列なら何でもいいです。ここでは GUID を使っています。

作成したリストから、「0詰めした件数」「0詰めしたタグ名順序」「タグ名」をセパレータで結合したリストを作成し、再度降順でソートします。0詰めするのは桁数が異なる数値同士を正しくソートさせるためです。

{% raw %}
```liquid
{% assign taglist_prepend_count = "" | split: "" %}
{% assign index = 0 %}
{% for t in taglist_alpha_reversed %}
    {% assign _t = t | split: separator %}

    {% comment %} 0詰め {% endcomment %}
    {% assign padded_count = _t[1] | prepend: "00000" | slice: -5, 5 %}
    {% assign padded_index = index | prepend: "00000" | slice: -5, 5  %}

    {% assign item = padded_count
        | append: separator | append: padded_index
        | append: separator | append: _t[0]
    %}

    {% assign taglist_prepend_count = taglist_prepend_count | push: item %}

    {% assign index = index | plus: 1 %}
{% endfor %}
{% assign taglist_prepend_count = taglist_prepend_count | sort | reverse %}
```
{% endraw %}

次に、タグ名と件数のリストを作成します。

{% raw %}
```liquid
{% assign taglist = "" | split: "" %}
{% for t in taglist_prepend_count %}
    {% assign _t = t | split: separator %}

    {% comment %} 0詰め文字列を数値に戻す {% endcomment %}
    {% assign count = _t[0] | plus: 0 %}

    {% assign item = "" | split: "" | push: _t[2] | push: count %}
    {% assign taglist = taglist | push: item %}
{% endfor %}
```
{% endraw %}

最後に、タグリストを出力します。

{% raw %}
```html
<ul>
{% for tag in taglist %}
    <li><a href="archive-by-tag.html#__tag__{{ tag[0] | uri_escape }}">{{ tag[0] }} ({{ tag[1] }})</a></li>
{% endfor %}
</ul>
```
{% endraw %}

## タグ別記事リスト

Github Pages では、タグ別の記事リストを単体の HTML ファイルとして出力することができないようです。

対応策として、すべての記事タイトルを含んだ HTML ファイルを用意し、URL のフラグメント部を基に CSS で表示を切り替えるようにして、疑似的に実現します。

まず、すべてのタグと、そのタグがつけられた記事一覧のリストを出力します。

{% raw %}
```html
{% for tag in site.tags %}
    <div id="__tag__{{ tag[0] | uri_escape }}" class="posts-with-tag">
        <h1>{{ tag[0] }}</h1>
        <ul>
            {% for post in site.posts %}
                {% if post.tags contains tag[0] %}
                    <li><a href="{{ post.url }}">{{ post.title }}</a></li>
                {% endif %}
            {% endfor %}
        </ul>
    </div>
{% endfor %}
```
{% endraw %}

あとは CSS に、

```css
.posts-with-tag:not(:target) {
    display: none;
}
```

と指定しておけば、`archive-by-tag.html#__tag__タグ名` でアクセスされたときに、当該タグの記事タイトルリストのみの表示になります。

※この方法だと、記事数が増えてくると HTML ファイルのサイズが大きくなりすぎるかもしれません。

# 月別アーカイブ

件数付き年月リストに関しては、Jekyll 側から月別ポスト件数の情報が与えられていないため、自力でカウントする必要があります。

まず、重複を含む年月リストを作成し、降順にソートします。

{% raw %}
```liquid
{% assign yearmonths_dupli = "" | split: "" %}
{% for post in site.posts %}
    {% assign ym = post.date | date: '%Y-%m' %}
    {% assign yearmonths_dupli = yearmonths_dupli | push: ym %}
{% endfor %}
{% assign yearmonths_dupli = yearmonths_dupli | sort | reverse %}
```
{% endraw %}

これで、例えば 2016 年 7 月に 2 件、8 月に 1 件、9 月に 1 件のポストがある場合、
`["2016-09", "2016-09", "2016-08", "2016-07", "2016-07"]` という配列が `yearmonths_dupli` に格納されます。

次に、`yearmonths_dupli` の重複を排除し、重複個数を加えた配列にします。

{% raw %}
```liquid
{% assign yearmonths = "" | split: "|" %}
{% assign count = 0 %}
{% assign prev = yearmonths_dupli | first %}
{% for ym in yearmonths_dupli %}
    {% if prev == ym %}
        {% assign count = count | plus: 1 %}
    {% else %}
        {% assign item = "" | split: "" | push: prev | push: count %}
        {% assign yearmonths = yearmonths | push: item %}
        {% assign count = 1 %}
    {% endif %}
    {% assign prev = ym %}
{% endfor %}
{% assign item = "" | split: "" | push: ym | push: count %}
{% assign yearmonths = yearmonths | push: item %}
```
{% endraw %}

これにより、`[["2016-09", 2], ["2016-08", 1], ["2016-07", 2]]` という配列が `yearmonths` に格納されます。

あとはタグのときと同様にリストに出力し、月別記事リストを作成すれば完成です。
