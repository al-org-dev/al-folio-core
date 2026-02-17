# frozen_string_literal: true

require_relative "test_helper"

class RuntimeAssetContractTest < Minitest::Test
  def test_giscus_setup_script_is_shipped_via_scripts_collection
    path = ROOT.join("_scripts/giscus-setup.js")
    assert path.file?, "expected #{path} to exist"

    content = path.read
    assert_includes content, "permalink: /assets/js/giscus-setup.js"
    assert_includes content, "https://giscus.app/client.js"
  end

  def test_cookie_plugin_wrappers_are_shipped
    styles_wrapper = ROOT.join("_includes/plugins/al_cookie_styles.liquid")
    scripts_wrapper = ROOT.join("_includes/plugins/al_cookie_scripts.liquid")

    assert styles_wrapper.file?, "expected #{styles_wrapper} to exist"
    assert scripts_wrapper.file?, "expected #{scripts_wrapper} to exist"
    assert_includes styles_wrapper.read, "{% al_cookie_styles %}"
    assert_includes scripts_wrapper.read, "{% al_cookie_scripts %}"
  end

  def test_scripts_include_uses_cookie_plugin_wrapper
    scripts_include = ROOT.join("_includes/scripts.liquid").read
    assert_includes scripts_include, "{% include plugins/al_cookie_scripts.liquid %}"
  end

  def test_head_include_uses_cookie_plugin_wrapper
    head_include = ROOT.join("_includes/head.liquid").read
    assert_includes head_include, "{% include plugins/al_cookie_styles.liquid %}"
  end

  def test_head_include_uses_icons_plugin_wrapper
    head_include = ROOT.join("_includes/head.liquid").read
    assert_includes head_include, "{% include plugins/al_icons_styles.liquid %}"
  end

  def test_back_to_top_uses_cdn_library_contract
    scripts_include = ROOT.join("_includes/scripts.liquid").read
    assert_includes scripts_include, "third_party_libraries['vanilla-back-to-top'].url.js"
  end
end
