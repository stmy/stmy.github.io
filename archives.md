---
layout: page
title:  "Archives"
---


<!-- Enumerate tags, add "Uncategorized" tag and sort it -->
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

<h2>By Tags</h2>
<ul class="archive-tag-list">
{% for tag in tags %}
    <li class="archive-tag-list-item">
        <a href="{{site.by_tag_page}}#{{site.tag_id_prefix}}{{tag[0] | slugify | uri_escape}}">
            {{ tag[0] }}
        </a>
    </li>
{% endfor %}
</ul>


<!-- Enumerate post year and months -->
{% assign yearmonths = "" | split:"|" %}
{% for post in site.posts %}
    {% assign ym = post.date | date: '%Y-%m' %}
    {% unless yearmonths contains ym %}
        {% assign yearmonths = yearmonths | push:ym %}
    {% endunless %}
{% endfor %}
{% assign yearmonths = yearmonths | sort %}

<h2>By Date</h2>
<ul class="archive-year-list">
{% assign years_added = "" | split:"|" %}
{% for _ym in yearmonths %}
    {% assign ym = _ym | split:"-" %}
    {% unless prev_year == ym[0] %} <!-- Start year -->
        {% if is_first == false %}</ul>{% endif %}
        <li class="archive-year-list-item">{{ym[0]}}
            <ul class="archive-month-list">
    {% endunless %}

    <li class="archive-month-list-item">
        <a href="{{site.by_month_page}}#{{site.month_id_prefix}}{{ym[0]}}_{{ym[1]}}">
            {% case ym[1] %}
                {% when "01" %} January
                {% when "02" %} February
                {% when "03" %} March
                {% when "04" %} April
                {% when "05" %} May
                {% when "06" %} June
                {% when "07" %} July
                {% when "08" %} August
                {% when "09" %} September
                {% when "10" %} October
                {% when "11" %} November
                {% when "12" %} December
            {% endcase %}
        </a>
    </li>

    {% if _ym == yearmonths.last %}
        </ul>
    {% endif %}
{% endfor %}
