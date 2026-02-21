#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "net/http"
require "time"
require "yaml"

APP_ID = ENV.fetch("IOS_APP_ID", "6748903433")
DATA_FILE = File.expand_path("../_data/releases.yml", __dir__)
LOCALES_FILE = File.expand_path("../_data/locales.yml", __dir__)

def load_country_by_lang(locales_file)
  locales_data = YAML.safe_load_file(locales_file) || {}
  locales = locales_data.fetch("locales", {})
  return {} unless locales.is_a?(Hash)

  locales.each_with_object({}) do |(lang, locale_config), memo|
    next unless locale_config.is_a?(Hash)

    country = locale_config["itunes_country"].to_s.strip
    next if country.empty?

    memo[lang.to_s] = country
  end
end

COUNTRY_BY_LANG = load_country_by_lang(LOCALES_FILE).freeze
raise "No locale countries found in #{LOCALES_FILE}" if COUNTRY_BY_LANG.empty?

def deep_copy(value)
  Marshal.load(Marshal.dump(value))
end

def fetch_lookup(app_id, country)
  uri = URI("https://itunes.apple.com/lookup?id=#{app_id}&country=#{country}")
  response = Net::HTTP.get_response(uri)
  raise "Lookup failed for country=#{country}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

  body = JSON.parse(response.body)
  result = body.fetch("results", []).first
  raise "No app result for app_id=#{app_id}, country=#{country}" if result.nil?

  result
end

def normalize_notes(text)
  return [] if text.nil? || text.strip.empty?

  text
    .split(/\r?\n/)
    .map(&:strip)
    .reject(&:empty?)
    .map { |line| line.sub(/\A[-*•]\s*/, "") }
end

def to_release_entry(result)
  {
    "version" => result.fetch("version").to_s,
    "released_at" => Date.parse(result.fetch("currentVersionReleaseDate")).iso8601,
    "notes" => normalize_notes(result["releaseNotes"])
  }
end

def ensure_data_shape(data)
  data["app_id"] = APP_ID if data["app_id"] != APP_ID
  data["releases"] = {} unless data["releases"].is_a?(Hash)
  data
end

def upsert_release!(entries, latest)
  existing_index = entries.index { |entry| entry["version"].to_s == latest["version"] }

  if existing_index.nil?
    entries.unshift(latest)
    true
  else
    merged = entries[existing_index].merge(latest)
    return false if merged == entries[existing_index]

    entries[existing_index] = merged
    true
  end
end

data = if File.exist?(DATA_FILE)
  YAML.safe_load_file(DATA_FILE) || {}
else
  {}
end

before_shape = deep_copy(data)
data = ensure_data_shape(data)
changed = data != before_shape

COUNTRY_BY_LANG.each do |lang, country|
  result = fetch_lookup(APP_ID, country)
  latest = to_release_entry(result)

  entries = deep_copy(data["releases"][lang] || [])
  changed_for_lang = upsert_release!(entries, latest)
  next unless changed_for_lang

  data["releases"][lang] = entries
  changed = true
end

if changed
  data["updated_at"] = Time.now.utc.iso8601

  File.write(DATA_FILE, YAML.dump(data, line_width: -1))
  puts "Updated #{DATA_FILE} for app #{APP_ID}"
else
  puts "No release changes detected for app #{APP_ID}"
end
