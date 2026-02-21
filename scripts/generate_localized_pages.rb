#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "fileutils"

repo_root = File.expand_path("..", __dir__)
data_path = File.join(repo_root, "_data", "page_locales.yml")
output_dir = File.join(repo_root, "_pages", "generated")
filename_prefix = "auto-"

unless File.exist?(data_path)
  warn "Missing localization data file: #{data_path}"
  exit 1
end

locales_data = YAML.load_file(data_path)
unless locales_data.is_a?(Hash)
  warn "Expected top-level mapping in #{data_path}"
  exit 1
end

FileUtils.mkdir_p(output_dir)
Dir.glob(File.join(output_dir, "#{filename_prefix}*.md")).each { |path| File.delete(path) }

generated_count = 0

locales_data.each do |page_key, page_locales|
  unless page_locales.is_a?(Hash)
    warn "Skipping #{page_key}: expected locale mapping"
    next
  end

  page_locales.each do |lang, page_config|
    unless page_config.is_a?(Hash)
      warn "Skipping #{page_key}/#{lang}: expected page config mapping"
      next
    end

    should_generate = page_config.key?("generate") ? page_config["generate"] : true
    next unless should_generate

    permalink = page_config["permalink"]
    if permalink.to_s.strip.empty?
      warn "Skipping #{page_key}/#{lang}: missing permalink"
      next
    end

    translation_key = page_config["translation_key"] || page_key
    layout = page_config["layout"] || "page"
    include_in_header = page_config.key?("include_in_header") ? page_config["include_in_header"] : false

    front_matter_data = {}
    front_matter_data["layout"] = layout
    front_matter_data["title"] = page_config["title"] if page_config.key?("title")
    front_matter_data["page_title"] = page_config["page_title"] if page_config.key?("page_title")
    front_matter_data["meta_description"] = page_config["meta_description"] if page_config.key?("meta_description")
    front_matter_data["include_in_header"] = include_in_header
    front_matter_data["nav_style"] = page_config["nav_style"] if page_config.key?("nav_style")
    front_matter_data["lang"] = lang
    front_matter_data["translation_key"] = translation_key
    front_matter_data["permalink"] = permalink

    reserved_keys = %w[
      include
      generate
      permalink
      translation_key
      lang
      layout
      title
      page_title
      meta_description
      include_in_header
      nav_style
    ]
    page_config.keys
               .map(&:to_s)
               .reject { |key| reserved_keys.include?(key) }
               .sort
               .each do |key|
      front_matter_data[key] = page_config[key]
    end

    front_matter_yaml = YAML.dump(front_matter_data, line_width: -1)
    front_matter_yaml = front_matter_yaml.sub(/\A---\s*\n/, "").sub(/\.\.\.\s*\n\z/, "")

    front_matter = []
    front_matter << "---"
    front_matter << front_matter_yaml.rstrip
    front_matter << "---"
    front_matter << ""
    front_matter << "{% include localized-page-content.html key=\"#{translation_key}\" %}"
    front_matter << ""

    safe_key = page_key.to_s.gsub(/[^a-zA-Z0-9_-]/, "-")
    safe_lang = lang.to_s.gsub(/[^a-zA-Z0-9_-]/, "-")
    output_path = File.join(output_dir, "#{filename_prefix}#{safe_key}-#{safe_lang}.md")

    File.write(output_path, front_matter.join("\n"))
    generated_count += 1
  end
end

puts "Generated #{generated_count} localized page stubs in #{output_dir}"
