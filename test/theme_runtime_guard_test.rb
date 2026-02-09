# frozen_string_literal: true

require_relative "test_helper"
require "al_folio_core"

class ThemeRuntimeGuardTest < Minitest::Test
  def test_local_source_asset_detection
    site_source = "/tmp/site"
    local_path = "/tmp/site/assets/js/app.js"
    gem_path = "/tmp/bundler/gems/al-folio-core-123/assets/js/app.js"

    assert AlFolioCore.local_source_asset?(local_path, site_source)
    refute AlFolioCore.local_source_asset?(gem_path, site_source)
  end

  def test_bootstrap_compat_assets_are_cache_busted
    head = ROOT.join("_includes/head.liquid").read
    scripts = ROOT.join("_includes/scripts.liquid").read
    distill_scripts = ROOT.join("_includes/distill_scripts.liquid").read

    assert_includes head, "bootstrap-compat.css' | relative_url | bust_file_cache"
    assert_includes scripts, "bootstrap-compat.js' | relative_url | bust_file_cache"
    assert_includes distill_scripts, "bootstrap-compat.js' | relative_url | bust_file_cache"
  end

  def test_theme_asset_path_points_to_packaged_assets
    tailwind_path = AlFolioCore.theme_asset_path("assets/css/tailwind.css")
    distill_path = AlFolioCore.theme_asset_path("assets/js/distillpub/transforms.v2.js")

    assert File.file?(tailwind_path), "expected #{tailwind_path} to exist"
    assert File.file?(distill_path), "expected #{distill_path} to exist"
  end
end
