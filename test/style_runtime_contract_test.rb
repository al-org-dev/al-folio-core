# frozen_string_literal: true

require_relative "test_helper"

class StyleRuntimeContractTest < Minitest::Test
  def test_utilities_scss_avoids_transition_all
    utilities_scss = ROOT.join("_sass/_utilities.scss").read
    refute_match(/transition\s*:\s*all\s+/i, utilities_scss)
  end

  def test_tailwind_entry_contract
    tailwind_app_css = ROOT.join("assets/tailwind/app.css").read

    assert_match(/@config\s+"..\/..\/tailwind\.config\.js";/, tailwind_app_css)
    assert_match(/@import\s+"tailwindcss\/theme\.css"\s+layer\(theme\);/, tailwind_app_css)
    assert_match(/@import\s+"tailwindcss\/utilities\.css"\s+layer\(utilities\);/, tailwind_app_css)
    refute_match(/@tailwind\s+base;|@tailwind\s+components;|@tailwind\s+utilities;/, tailwind_app_css)
  end

  # Classes defined by any stylesheet core ships: the prebuilt Tailwind output
  # plus every Sass partial. A Tailwind utility only works if it was present in
  # the content scanned when tailwind.css was last built, and nothing rebuilds
  # it when a template changes.
  def defined_classes
    tailwind = ROOT.join("assets/css/tailwind.css").read.gsub(%r{/\*.*?\*/}m, "")
    from_tailwind = tailwind.scan(/\.((?:\\.|[A-Za-z0-9_-])+)/).flatten.map { |c| c.gsub(/\\(.)/, '\1') }
    from_sass = Dir[ROOT.join("_sass/**/*.scss").to_s].flat_map { |f| File.read(f).scan(/\.([A-Za-z_][\w-]*)/).flatten }
    (from_tailwind + from_sass).uniq
  end

  def test_related_posts_only_uses_defined_classes
    # al-org-dev/al-folio-core#55: this include used six utilities (pl-7,
    # space-y-2, marker:..., ...) that were never in the prebuilt tailwind.css,
    # so the list silently fell back to browser defaults.
    template = ROOT.join("_includes/related_posts.liquid").read
    used = template.scan(/class="([^"]*)"/).flatten.flat_map(&:split).reject { |c| c.include?("{") }
    # Not a style hook: the external-link icon sets its stroke inline.
    allowed_unstyled = %w[icon_svg-stroke]

    missing = used.uniq - allowed_unstyled - defined_classes
    assert_empty missing, "related_posts.liquid uses classes no shipped stylesheet defines: #{missing.join(", ")}"
  end

  def test_repository_template_class_contract
    repository_include = ROOT.join("_includes/repository/repo.liquid").read
    repository_user_include = ROOT.join("_includes/repository/repo_user.liquid").read

    assert_includes repository_include, 'class="repo p-2 text-center"'
    assert_includes repository_user_include, 'class="repo p-2 text-center"'
  end
end
