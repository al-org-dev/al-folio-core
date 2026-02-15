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

  def test_cookie_consent_setup_include_is_shipped
    path = ROOT.join("_includes/plugins/al_cookie_consent_setup.liquid")
    assert path.file?, "expected #{path} to exist"

    content = path.read
    assert_includes content, "window.CookieConsent.run"
    assert_includes content, "window.gtag"
  end

  def test_scripts_include_uses_inline_cookie_consent_setup
    scripts_include = ROOT.join("_includes/scripts.liquid").read
    assert_includes scripts_include, "{% include plugins/al_cookie_consent_setup.liquid %}"
    refute_includes scripts_include, "/assets/js/cookie-consent-setup.js"
  end
end
