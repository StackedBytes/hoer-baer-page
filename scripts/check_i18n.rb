#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"

REPO_ROOT = File.expand_path("..", __dir__)
LOCALES_PATH = File.join(REPO_ROOT, "_data", "locales.yml")
I18N_PATH = File.join(REPO_ROOT, "_data", "i18n.yml")
PAGE_LOCALES_PATH = File.join(REPO_ROOT, "_data", "page_locales.yml")
INCLUDES_ROOT = File.join(REPO_ROOT, "_includes")
SCAN_ROOTS = [
  File.join(REPO_ROOT, "_includes"),
  File.join(REPO_ROOT, "_layouts")
].freeze

def load_yaml(path)
  YAML.safe_load_file(path) || {}
rescue StandardError => e
  raise "Failed to load YAML at #{path}: #{e.message}"
end

def compare_structure(reference, candidate, path, errors)
  if reference.is_a?(Hash)
    unless candidate.is_a?(Hash)
      errors << "#{path}: expected Hash, got #{candidate.class}"
      return
    end

    ref_keys = reference.keys.map(&:to_s)
    cand_keys = candidate.keys.map(&:to_s)

    missing_keys = ref_keys - cand_keys
    extra_keys = cand_keys - ref_keys

    missing_keys.each { |key| errors << "#{path}: missing key `#{key}`" }
    extra_keys.each { |key| errors << "#{path}: unexpected key `#{key}`" }

    (ref_keys & cand_keys).sort.each do |key|
      compare_structure(reference[key], candidate[key], "#{path}.#{key}", errors)
    end
    return
  end

  if reference.is_a?(Array)
    unless candidate.is_a?(Array)
      errors << "#{path}: expected Array, got #{candidate.class}"
      return
    end

    return if reference.empty? || candidate.empty?

    template = reference.first
    candidate.each_with_index do |item, index|
      compare_structure(template, item, "#{path}[#{index}]", errors)
    end
    return
  end

  if candidate.is_a?(Hash) || candidate.is_a?(Array)
    errors << "#{path}: expected #{reference.class}, got #{candidate.class}"
    return
  end

  return if reference.nil? && candidate.nil?
  return if !candidate.nil? && candidate.class == reference.class

  errors << "#{path}: expected #{reference.class}, got #{candidate.class}"
end

def check_hardcoded_language_logic(errors)
  patterns = [
    { regex: /\bwhere:\s*"lang",\s*"(de|en)"\b/, label: "Hardcoded language filter" },
    { regex: /\?lang=(de|en)\b/, label: "Hardcoded language query" },
    { regex: /(?:==|!=|===|!==)\s*["'](?:de|en|de-DE|en-US)["']/, label: "Hardcoded language comparison" },
    { regex: /\bsite\.data\.i18n\.(de|en)\b/, label: "Hardcoded i18n locale access" },
    { regex: /\breleases\.releases\.(de|en)\b/, label: "Hardcoded release locale access" }
  ]

  file_paths = SCAN_ROOTS.flat_map { |root| Dir.glob(File.join(root, "**", "*.{html,md,rb,js}")) }.sort
  file_paths.each do |file_path|
    File.readlines(file_path, chomp: true).each_with_index do |line, index|
      patterns.each do |pattern|
        next unless line.match?(pattern[:regex])

        rel_path = file_path.sub("#{REPO_ROOT}/", "")
        errors << "#{rel_path}:#{index + 1}: #{pattern[:label]} -> `#{line.strip}`"
      end
    end
  end
end

errors = []

locales_data = load_yaml(LOCALES_PATH)
i18n_data = load_yaml(I18N_PATH)
page_locales_data = load_yaml(PAGE_LOCALES_PATH)

default_locale_code = locales_data["default_locale"].to_s.strip
locales_map = locales_data["locales"]
locale_order = locales_data["order"]

unless locales_map.is_a?(Hash) && !locales_map.empty?
  errors << "_data/locales.yml: `locales` must be a non-empty mapping"
end

if default_locale_code.empty?
  errors << "_data/locales.yml: `default_locale` is missing"
end

ordered_locales = if locale_order.is_a?(Array) && !locale_order.empty?
  locale_order.map(&:to_s)
else
  locales_map.to_h.keys.map(&:to_s)
end

if !default_locale_code.empty? && !ordered_locales.include?(default_locale_code)
  errors << "_data/locales.yml: `default_locale` (#{default_locale_code}) must be present in `order`"
end

if locales_map.is_a?(Hash)
  locale_keys = locales_map.keys.map(&:to_s)
  missing_in_order = locale_keys - ordered_locales
  extra_in_order = ordered_locales - locale_keys
  missing_in_order.each { |key| errors << "_data/locales.yml: locale `#{key}` missing in `order`" }
  extra_in_order.each { |key| errors << "_data/locales.yml: locale `#{key}` in `order` has no locale config" }
end

if i18n_data.is_a?(Hash)
  reference_locale = i18n_data[default_locale_code]
  if reference_locale.nil?
    errors << "_data/i18n.yml: missing default locale section `#{default_locale_code}`"
  else
    ordered_locales.each do |locale_code|
      candidate_locale = i18n_data[locale_code]
      if candidate_locale.nil?
        errors << "_data/i18n.yml: missing locale section `#{locale_code}`"
        next
      end

      compare_structure(reference_locale, candidate_locale, "i18n.#{locale_code}", errors)
    end
  end
else
  errors << "_data/i18n.yml: expected top-level mapping"
end

required_page_fields = %w[permalink title page_title meta_description include].freeze

if page_locales_data.is_a?(Hash)
  page_locales_data.each do |page_key, localized_configs|
    unless localized_configs.is_a?(Hash)
      errors << "_data/page_locales.yml: `#{page_key}` must map locales to config objects"
      next
    end

    locale_keys = localized_configs.keys.map(&:to_s)
    missing_locales = ordered_locales - locale_keys
    extra_locales = locale_keys - ordered_locales

    missing_locales.each { |locale| errors << "_data/page_locales.yml: `#{page_key}` missing locale `#{locale}`" }
    extra_locales.each { |locale| errors << "_data/page_locales.yml: `#{page_key}` has unsupported locale `#{locale}`" }

    ordered_locales.each do |locale_code|
      locale_config = localized_configs[locale_code]
      unless locale_config.is_a?(Hash)
        errors << "_data/page_locales.yml: `#{page_key}.#{locale_code}` must be a mapping"
        next
      end

      required_page_fields.each do |field|
        value = locale_config[field]
        if value.to_s.strip.empty?
          errors << "_data/page_locales.yml: `#{page_key}.#{locale_code}.#{field}` must be set"
        end
      end

      permalink = locale_config["permalink"].to_s
      if !permalink.empty? && !permalink.start_with?("/")
        errors << "_data/page_locales.yml: `#{page_key}.#{locale_code}.permalink` must start with `/`"
      end

      include_path = locale_config["include"].to_s
      unless include_path.empty?
        absolute_include = File.join(INCLUDES_ROOT, include_path)
        unless File.exist?(absolute_include)
          errors << "_data/page_locales.yml: include not found for `#{page_key}.#{locale_code}` -> #{include_path}"
        end
      end
    end
  end
else
  errors << "_data/page_locales.yml: expected top-level mapping"
end

check_hardcoded_language_logic(errors)

if errors.empty?
  puts "i18n checks passed"
  exit 0
end

puts "i18n checks failed:"
errors.each { |error| puts "- #{error}" }
exit 1
