# Impressum

Angaben gemaess § 5 ECG:

Benjamin Rudhart  
Burgstaller Str. 2  
8143 Dobl  
Oesterreich

E-Mail: support@hoerbaer.app  
UID: ATU78965657

{% assign locale_config = site.data.locales %}
{% assign default_locale_code = locale_config.default_locale | default: "en" %}
{% assign current_lang = page.lang | default: default_locale_code %}
{% assign t = site.data.i18n[current_lang] | default: site.data.i18n[default_locale_code] %}

## {{ t.legal.notice_heading | default: "Hinweis zu Marken und Urheberrecht" }}

{{ t.legal.screenshots_editorial_notice | default: "Die im Press Kit bereitgestellten Screenshots dürfen für die redaktionelle Berichterstattung über die App HörBär verwendet werden. In den Screenshots können urheber- und markenrechtlich geschützte Inhalte Dritter enthalten sein; die Rechte daran liegen bei den jeweiligen Inhabern. Apple Music ist eine eingetragene Marke der Apple Inc." }}
