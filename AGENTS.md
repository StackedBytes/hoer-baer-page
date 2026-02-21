# AGENTS.md

This file defines working rules for agents in this repository.

## Project context

- Type: Jekyll-based GitHub Pages landing page
- Entry point: `_config.yml` controls most content and colors
- Relevant folders:
  - `_pages/` for legal/additional pages
  - `assets/` for images, videos, and static files
  - `_includes/`, `_layouts/`, `_sass/` for template/styling adjustments

## Setup

1. Ruby/Bundler must be available.
2. Install dependencies:
   - `bundle install`

## Local development

- Generate localized page stubs before local build/serve:
  - `./scripts/generate-localized-pages.sh`
- Run i18n checks:
  - `ruby ./scripts/check_i18n.rb`
- Start the dev server:
  - `bundle exec jekyll serve`
- Optional with live reload:
  - `bundle exec jekyll serve --livereload`
- Verify production build:
  - `bundle exec jekyll build`

## Working rules

- Work primarily in `_config.yml` for content/theme updates.
- Do not manually edit `_site/` (generated output).
- Do not manually edit generated localized page stubs in `_pages/generated/`; update `_data/page_locales.yml` and localized content includes instead.
- Place assets in the matching folder:
  - Screenshots: `assets/screenshot/`
  - Videos: `assets/videos/`
- Keep existing structure and naming conventions.
- Localize English content and metadata consistently as `en-US` (US terminology, US spelling, matching locale tags).
- Write all git commit messages in English.
- Keep changes small and focused.

## Localization requirements

- Localization rules apply to all current and future locales.
- Current project locales are `en-US` and `de-DE`, but do not hardcode the process to only these two.
- Use locale-consistent language tags in HTML/meta (BCP 47, e.g. `en-US`, `de-DE`) and matching OG locale values (e.g. `en_US`, `de_DE`).
- Keep URLs language-scoped:
  - Primary locale may use root paths (for example `/...`)
  - Additional locales use explicit locale prefixes (for example `/de/...`)
- For each translated page pair, set all of:
  - `lang`
  - `permalink`
  - `translation_key` (same value in both language files)
- Do not hardcode user-facing copy in `_includes/` or `_layouts/` when it can be localized. Store copy in `_data/i18n.yml` and reference keys.
- Localize metadata and accessibility text:
  - `<title>`, meta description, OG/Twitter title/description
  - image `alt` text and ARIA labels
- Ensure language switch links resolve to the matching translated page (not only home) for pages with a `translation_key`.
- Add/maintain `hreflang` links for translated page pairs (all supported locales plus `x-default`).
- Keep legal/business terms locale-appropriate and consistent for each locale (for example, US English wording for `en-US`).

## Before handoff

1. `./scripts/generate-localized-pages.sh` runs without errors.
2. `ruby ./scripts/check_i18n.rb` runs without errors.
3. `bundle exec jekyll build` runs without errors.
4. Check changed pages/styles locally in `bundle exec jekyll serve`.
5. Validate links and asset paths in `_config.yml` and Markdown pages.
6. Validate localization behavior for changed pages:
   - all localized URLs render correctly
   - language switch points to the corresponding translated page
   - localized metadata (`title`, description, OG/Twitter) is correct for each locale
   - `hreflang` entries are present and correct for translated pages
