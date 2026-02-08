# frozen_string_literal: true

require "jekyll"
require_relative "al_folio_core/version"

module AlFolioCore
  LEGACY_PATTERN = /data-toggle\s*=\s*["'](?:collapse|dropdown|tooltip|popover|table)["']|\b(?:navbar|card|btn|row|col-(?:xs|sm|md|lg)-\d+)\b/

  module_function

  def compat_enabled?(site)
    site.config.dig("al_folio", "compat", "bootstrap", "enabled") == true
  end

  def markdown_and_template_files(site)
    roots = %w[_pages _posts _includes _layouts _books _projects _teachings]
    roots.flat_map do |root|
      Dir.glob(File.join(site.source, root, "**", "*.{md,markdown,html,liquid}"))
    end
  end

  def legacy_hits(site, limit: 5)
    hits = []

    markdown_and_template_files(site).each do |path|
      next unless File.file?(path)

      File.foreach(path).with_index(1) do |line, index|
        next unless line.match?(LEGACY_PATTERN)

        rel = path.sub(%r{^#{Regexp.escape(site.source)}/?}, "")
        hits << "#{rel}:#{index}"
        return hits if hits.length >= limit
      end
    end

    hits
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  api_version = site.config.dig("al_folio", "api_version")
  unless api_version == 1
    Jekyll.logger.warn("al_folio_core:", "expected `al_folio.api_version: 1` but found #{api_version.inspect}")
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  next if AlFolioCore.compat_enabled?(site)

  hits = AlFolioCore.legacy_hits(site)
  next if hits.empty?

  Jekyll.logger.warn("al_folio_core:", "legacy bootstrap-marked content detected while compatibility is disabled")
  Jekyll.logger.warn("al_folio_core:", "set `al_folio.compat.bootstrap.enabled: true` or run `bundle exec al-folio upgrade audit`")
  hits.each do |hit|
    Jekyll.logger.warn("al_folio_core:", "  #{hit}")
  end
end
