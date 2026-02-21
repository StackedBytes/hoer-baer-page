# Release Notes
Here are the latest changes and improvements for the HoerBaer app.

{% assign default_locale_code = site.data.locales.default_locale | default: "en" %}
{% assign release_lang = page.lang | default: default_locale_code %}
{% assign releases = site.data.releases.releases[release_lang] | default: site.data.releases.releases[default_locale_code] %}
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
