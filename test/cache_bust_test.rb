# frozen_string_literal: true

require_relative "test_helper"
require "digest/md5"
require "fileutils"
require "jekyll"
require "tmpdir"

# jekyll-cache-bust is a dependency of the starter, not of this gem, so CI here
# cannot load it. This is its 0.0.1 CacheDigester verbatim in behaviour: core
# prepends a module onto this exact class, so the test exercises the same seam.
unless defined?(Jekyll::CacheBust::CacheDigester)
  module Jekyll
    module CacheBust
      class CacheDigester
        attr_accessor :file_name, :directory

        def initialize(file_name:, directory: nil)
          self.file_name = file_name
          self.directory = directory
        end

        def digest!
          [file_name, "?v=", Digest::MD5.hexdigest(file_contents)].join
        end

        private

        def directory_files_content
          Dir[File.join(directory, "**", "*")].map { |f| File.read(f) unless File.directory?(f) }.join
        end

        def file_contents
          directory_files_content
        end
      end
    end
  end
end

require "al_folio_core"
AlFolioCore.patch_jekyll_cache_bust_for_theme_assets!

class CacheBustTest < Minitest::Test
  EMPTY_DIGEST = Digest::MD5.hexdigest("")

  def setup
    Jekyll.logger.log_level = :error
  end

  # What `{{ '/assets/css/main.css' | bust_css_cache }}` computes.
  def css_digest
    Jekyll::CacheBust::CacheDigester.new(file_name: "/assets/css/main.css", directory: "assets/_sass")
                                    .digest!.split("?v=").last
  end

  def with_site(config = {})
    Dir.mktmpdir do |dir|
      Jekyll::Site.new(Jekyll.configuration(config.merge("source" => dir, "destination" => File.join(dir, "_site"),
                                                         "quiet" => true)))
      yield dir
    end
  end

  def test_digest_covers_the_theme_partials
    # Regression for the original fallback: without it the glob matched nothing
    # and the digest was the MD5 of "", so theme changes never re-versioned CSS.
    with_site do
      refute_equal EMPTY_DIGEST, css_digest
    end
  end

  def test_editing_a_local_sass_override_changes_the_digest
    # al-org-dev/al-folio-core#43: local _sass partials shadow the theme's and
    # compile into the same main.css, but were never read, so main.css?v= stayed
    # put and browsers kept serving the stale stylesheet after an edit.
    with_site do |dir|
      FileUtils.mkdir_p(File.join(dir, "_sass"))
      partial = File.join(dir, "_sass", "_variables.scss")

      File.write(partial, "$theme-color: #b509ac;\n")
      before = css_digest
      File.write(partial, "$theme-color: #0076df;\n")
      after = css_digest

      refute_equal before, after
    end
  end

  def test_adding_a_local_override_changes_the_digest
    with_site do |dir|
      theme_only = css_digest
      FileUtils.mkdir_p(File.join(dir, "_sass"))
      File.write(File.join(dir, "_sass", "_themes.scss"), ":root { --global-theme-color: red; }\n")

      refute_equal theme_only, css_digest
    end
  end

  def test_honours_a_configured_sass_dir
    with_site("sass" => { "sass_dir" => "_styles" }) do |dir|
      FileUtils.mkdir_p(File.join(dir, "_styles"))
      partial = File.join(dir, "_styles", "_variables.scss")

      File.write(partial, "$a: 1;\n")
      before = css_digest
      File.write(partial, "$a: 2;\n")

      refute_equal before, css_digest
    end
  end

  def test_sites_without_local_partials_keep_their_digest
    # A site with no local partials must get exactly the digest it got before
    # this fix (the theme's partials alone), or every site would bust its CSS
    # cache on upgrade for no reason.
    theme_only = Dir[File.join(AlFolioCore::THEME_ROOT, "_sass", "**", "*")]
                 .map { |f| File.read(f) unless File.directory?(f) }.join

    with_site do
      assert_equal Digest::MD5.hexdigest(theme_only), css_digest
    end
  end
end
