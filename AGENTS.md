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

- Start the dev server:
  - `bundle exec jekyll serve`
- Optional with live reload:
  - `bundle exec jekyll serve --livereload`
- Verify production build:
  - `bundle exec jekyll build`

## Working rules

- Work primarily in `_config.yml` for content/theme updates.
- Do not manually edit `_site/` (generated output).
- Place assets in the matching folder:
  - Screenshots: `assets/screenshot/`
  - Videos: `assets/videos/`
- Keep existing structure and naming conventions.
- Localize English content and metadata consistently as `en-US` (US terminology, US spelling, matching locale tags).
- Write all git commit messages in English.
- Keep changes small and focused.

## Before handoff

1. `bundle exec jekyll build` runs without errors.
2. Check changed pages/styles locally in `bundle exec jekyll serve`.
3. Validate links and asset paths in `_config.yml` and Markdown pages.
