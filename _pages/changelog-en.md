---
layout: page
title: Changelog
include_in_header: false
lang: en
permalink: /changelog/
translation_key: changelog
---

# Release Notes
Here are the latest changes and improvements for the HoerBaer app. This page is updated automatically from the App Store.

{% assign releases = site.data.releases.releases.en %}
{% if releases and releases.size > 0 %}
{% for release in releases %}
## Version {{ release.version }} · {{ release.released_at | date: "%B %-d, %Y" }}
{% if release.notes and release.notes.size > 0 %}
{% for note in release.notes %}
- {{ note }}
{% endfor %}
{% else %}
- No additional notes available.
{% endif %}

{% endfor %}
{% else %}
No release data available.
{% endif %}
