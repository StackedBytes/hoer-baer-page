---
layout: page
title: Changelog
include_in_header: false
lang: en
permalink: /changelog/
translation_key: changelog
---

# Release Notes
Here are the latest changes and improvements for the HoerBaer app.

{% assign releases = site.data.releases.releases.en %}
{% if releases and releases.size > 0 %}
{% for release in releases %}
<details class="changelogEntry"{% if forloop.first %} open{% endif %}>
  <summary>
    <span class="changelogVersion">Version {{ release.version }}</span>
    <span class="changelogDate">{{ release.released_at | date: "%B %-d, %Y" }}</span>
  </summary>
  <div class="changelogContent">
    {% if release.notes and release.notes.size > 0 %}
    <ul class="changelogNotes">
      {% for note in release.notes %}
      <li>{{ note }}</li>
      {% endfor %}
    </ul>
    {% else %}
    <p class="changelogEmpty">No additional notes available.</p>
    {% endif %}
  </div>
</details>
{% endfor %}
{% else %}
No release data available.
{% endif %}
