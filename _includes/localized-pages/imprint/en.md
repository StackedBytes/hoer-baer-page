# Imprint

Information pursuant to Section 5 of the Austrian E-Commerce Act (ECG):

Benjamin Rudhart  
Burgstaller Str. 2  
8143 Dobl  
Austria

Email: support@hoerbaer.app  
VAT ID: ATU78965657

{% assign locale_config = site.data.locales %}
{% assign default_locale_code = locale_config.default_locale | default: "en" %}
{% assign current_lang = page.lang | default: default_locale_code %}
{% assign t = site.data.i18n[current_lang] | default: site.data.i18n[default_locale_code] %}

## {{ t.legal.notice_heading | default: "Trademark and Copyright Notice" }}

{{ t.legal.screenshots_editorial_notice | default: "The screenshots provided in this press kit may be used for editorial coverage of the HoerBaer app. Screenshots may include third-party copyrighted and trademarked content; rights to such content remain with their respective owners. Apple Music is a registered trademark of Apple Inc." }}
