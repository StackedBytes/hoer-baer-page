---
layout: page
title: Neuigkeiten
include_in_header: false
lang: de
permalink: /de/changelog/
translation_key: changelog
---

# Versionshinweise
Hier findest du aktuelle Änderungen und Verbesserungen der HörBär-App. Diese Seite wird automatisch aus dem App Store aktualisiert.

{% assign releases = site.data.releases.releases.de %}
{% if releases and releases.size > 0 %}
{% for release in releases %}
## Version {{ release.version }} · {{ release.released_at | date: "%d.%m.%Y" }}
{% if release.notes and release.notes.size > 0 %}
{% for note in release.notes %}
- {{ note }}
{% endfor %}
{% else %}
- Keine weiteren Hinweise verfügbar.
{% endif %}

{% endfor %}
{% else %}
Keine Versionsdaten verfügbar.
{% endif %}
