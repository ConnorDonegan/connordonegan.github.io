---
layout: page
title: Blog
permalink: /blog/
---

<div class="home">
    <ul class="post-list">
      {%- for post in site.posts -%}
      <li>
        {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}

          <span class="post-meta" style="display: inline;">{{ post.date | date: date_format }}</span>
          <a class="post-link" style="display: inline;" href="{{ post.url | relative_url }}">
            {{ post.title }}
          </a>
      </li> 
      {%- endfor -%}
    </ul>
 </div> 
