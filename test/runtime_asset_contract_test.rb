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

  def test_cookie_consent_setup_script_is_shipped_via_scripts_collection
    path = ROOT.join("_scripts/cookie-consent-setup.js")
    assert path.file?, "expected #{path} to exist"

    content = path.read
    assert_includes content, "permalink: /assets/js/cookie-consent-setup.js"
    assert_includes content, "window.CookieConsent.run"
  end
end
