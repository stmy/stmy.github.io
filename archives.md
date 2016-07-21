---
layout: page
title:  "Archives"
---

{% assign tags = "" | split:"|" %}
{% assign tags_tmp = "" | split:"|" %}
{% for site_tag in site.tags %}
    {% assign tag = site_tag | join:"|" %}
    {% assign tags_tmp = tags_tmp | push:tag %}
{% endfor %}
{% unless tags_tmp contains site.unassigned %}
    {% assign tags_tmp = tags_tmp | push:site.unassigned %}
{% endunless %}
{% assign tags_tmp = tags_tmp | sort %}
{% for tag_tmp in tags_tmp %}
    {% assign tag = tag_tmp | split:"|" %}
    {% assign tags = tags | push:tag %}
{% endfor %}

# By Tags

{% for tag in tags %}
+ [{{ tag[0] }}](/archives-by-tags.html#__tag__{{ tag[0] | slugify | uri_escape }})
{% endfor %}

# By Date

+ Under construction...
