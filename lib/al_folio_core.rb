# frozen_string_literal: true

require "jekyll"
require_relative "al_folio_core/version"

module AlFolioCore
  LEGACY_PATTERN = /data-toggle\s*=\s*["'](?:collapse|dropdown|tooltip|popover|table)["']|\b(?:navbar|card|btn|row|col-(?:xs|sm|md|lg)-\d+)\b/
  DISTILL_REMOTE_LOADER_PATTERN = %r{https://distill\.pub/template\.v2\.js}
  MIGRATIONS_DIR = File.expand_path("../migrations", __dir__)

  module_function

  def compat_enabled?(site)
    site.config.dig("al_folio", "compat", "bootstrap", "enabled") == true
  end

  def remote_distill_loader_allowed?(site)
    site.config.dig("al_folio", "distill", "allow_remote_loader") == true
  end

  def distill_transforms_path(site)
    File.join(site.source, "assets", "js", "distillpub", "transforms.v2.js")
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

  def migration_manifest_paths
    Dir.glob(File.join(MIGRATIONS_DIR, "*.yml")).sort
  end

  def config_contract_violations(site)
    violations = []
    cfg = site.config
    api_version = cfg.dig("al_folio", "api_version")
    style_engine = cfg.dig("al_folio", "style_engine")
    tailwind_version = cfg.dig("al_folio", "tailwind", "version")
    tailwind_preflight = cfg.dig("al_folio", "tailwind", "preflight")
    tailwind_css_entry = cfg.dig("al_folio", "tailwind", "css_entry")
    distill_engine = cfg.dig("al_folio", "distill", "engine")
    distill_source = cfg.dig("al_folio", "distill", "source")

    violations << "expected `al_folio.api_version: 1` but found #{api_version.inspect}" unless api_version == 1
    violations << "expected `al_folio.style_engine: tailwind` but found #{style_engine.inspect}" unless style_engine == "tailwind"
    violations << "missing `al_folio.tailwind.version`" if tailwind_version.to_s.strip.empty?
    violations << "expected `al_folio.tailwind.preflight: false` for v1 parity mode" unless tailwind_preflight == false
    violations << "missing `al_folio.tailwind.css_entry`" if tailwind_css_entry.to_s.strip.empty?
    violations << "missing `al_folio.distill.engine`" if distill_engine.to_s.strip.empty?
    violations << "missing `al_folio.distill.source`" if distill_source.to_s.strip.empty?
    violations
  end
end

Jekyll::Hooks.register :site, :after_init do |site|
  AlFolioCore.config_contract_violations(site).each do |violation|
    Jekyll.logger.warn("al_folio_core:", violation)
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  if !AlFolioCore.remote_distill_loader_allowed?(site)
    transforms_path = AlFolioCore.distill_transforms_path(site)
    if File.file?(transforms_path)
      content = File.read(transforms_path)
      if content.match?(AlFolioCore::DISTILL_REMOTE_LOADER_PATTERN)
        rel = transforms_path.sub(%r{^#{Regexp.escape(site.source)}/?}, "")
        Jekyll.logger.warn("al_folio_core:", "remote Distill loader detected in #{rel} while `al_folio.distill.allow_remote_loader` is false")
      end
    end
  end

  unless AlFolioCore.compat_enabled?(site)
    hits = AlFolioCore.legacy_hits(site)
    unless hits.empty?
      Jekyll.logger.warn("al_folio_core:", "legacy bootstrap-marked content detected while compatibility is disabled")
      Jekyll.logger.warn("al_folio_core:", "set `al_folio.compat.bootstrap.enabled: true` or run `bundle exec al-folio upgrade audit`")
      hits.each do |hit|
        Jekyll.logger.warn("al_folio_core:", "  #{hit}")
      end
    end
  end

  manifests = AlFolioCore.migration_manifest_paths
  if manifests.empty?
    Jekyll.logger.warn("al_folio_core:", "no migration manifests found under #{AlFolioCore::MIGRATIONS_DIR}")
  end
end
