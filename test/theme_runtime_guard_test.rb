# frozen_string_literal: true

require_relative "test_helper"
require "al_folio_core"

class ThemeRuntimeGuardTest < Minitest::Test
  LEGACY_OR_PLUGIN_OWNED_ASSETS = %w[
    assets/css/bootstrap-toc.min.css
    assets/css/bootstrap.min.css
    assets/css/mdb.min.css
    assets/css/tikzjax.min.css
    assets/js/bootstrap-toc.min.js
    assets/js/bootstrap.bundle.min.js
    assets/js/chartjs-setup.js
    assets/js/diff2html-setup.js
    assets/js/echarts-setup.js
    assets/js/leaflet-setup.js
    assets/js/mathjax-setup.js
    assets/js/mermaid-setup.js
    assets/js/newsletter.js
    assets/js/plotly-setup.js
    assets/js/pseudocode-setup.js
    assets/js/search-setup.js
    assets/js/shortcut-key.js
    assets/js/tikzjax.min.js
    assets/js/vega-setup.js
  ].freeze

  def test_local_source_asset_detection
    site_source = "/tmp/site"
    local_path = "/tmp/site/assets/js/app.js"
    gem_path = "/tmp/bundler/gems/al-folio-core-123/assets/js/app.js"
    vendored_bundle_path = "/tmp/site/vendor/bundle/ruby/3.3.0/gems/al_folio_core-1.1.0/assets/js/app.js"

    assert AlFolioCore.local_source_asset?(local_path, site_source)
    refute AlFolioCore.local_source_asset?(gem_path, site_source)
    refute AlFolioCore.local_source_asset?(vendored_bundle_path, site_source)
  end

  def test_bootstrap_compat_assets_are_cache_busted
    head = ROOT.join("_includes/head.liquid").read
    scripts = ROOT.join("_includes/scripts.liquid").read

    assert_includes head, "bootstrap-compat.css' | relative_url | bust_file_cache"
    assert_includes scripts, "bootstrap-compat.js' | relative_url | bust_file_cache"
  end

  def test_theme_asset_path_points_to_packaged_assets
    tailwind_path = AlFolioCore.theme_asset_path("assets/css/tailwind.css")
    compat_css_path = AlFolioCore.theme_asset_path("assets/css/bootstrap-compat.css")
    compat_js_path = AlFolioCore.theme_asset_path("assets/js/bootstrap-compat.js")
    cv_include_path = AlFolioCore.theme_asset_path("_includes/cv/education.liquid")
    distill_scripts_include_path = AlFolioCore.theme_asset_path("_includes/distill_scripts.liquid")

    assert File.file?(tailwind_path), "expected #{tailwind_path} to exist"
    refute File.file?(compat_css_path), "bootstrap compat CSS should be owned by al_folio_bootstrap_compat"
    refute File.file?(compat_js_path), "bootstrap compat JS should be owned by al_folio_bootstrap_compat"
    refute File.file?(cv_include_path), "cv includes should be owned by al_folio_cv"
    refute File.file?(distill_scripts_include_path), "distill scripts include should be owned by al_folio_distill"
  end

  def test_bundler_gem_asset_paths_can_locate_core_assets
    paths = AlFolioCore.bundler_gem_asset_paths("assets/css/tailwind.css")
    assert paths.is_a?(Array)
    assert paths.all? { |path| File.file?(path) }
  end

  def test_wrapper_layouts_delegate_to_plugin_includes
    cv_layout = ROOT.join("_layouts/cv.liquid").read
    distill_layout = ROOT.join("_layouts/distill.liquid").read

    assert_includes cv_layout, "{% al_folio_cv_render %}"
    assert_includes distill_layout, "{% al_folio_distill_render %}"
  end

  def test_legacy_and_plugin_owned_assets_are_not_packaged_by_core
    LEGACY_OR_PLUGIN_OWNED_ASSETS.each do |asset_path|
      refute ROOT.join(asset_path).file?, "expected #{asset_path} to be removed from al_folio_core"
    end
  end

  def test_jupyter_plugin_detection_and_command_checks
    enabled_site = Struct.new(:config).new({ "plugins" => ["jekyll-jupyter-notebook"] })
    disabled_site = Struct.new(:config).new({ "plugins" => ["jekyll-feed"] })

    assert AlFolioCore.jupyter_plugin_enabled?(enabled_site)
    refute AlFolioCore.jupyter_plugin_enabled?(disabled_site)
    assert AlFolioCore.command_available?("ruby")
  end
end
