# frozen_string_literal: true

require_relative "test_helper"
require "fileutils"
require "jekyll"
require "tmpdir"

class ProjectHighlightsSocialLinksTag < Liquid::Tag
  def render(_context)
    ""
  end
end

Liquid::Template.register_tag("social_links", ProjectHighlightsSocialLinksTag)

# Exercise the about layout and project-highlights include together in a minimal Jekyll site.
# This keeps the contract covered without coupling the core gem to the starter's full fixture.
class ProjectHighlightsTest < Minitest::Test
  def render_page(project_highlights: :omitted)
    Dir.mktmpdir("al-folio-project-highlights-") do |source|
      destination = File.join(source, "_site")
      FileUtils.mkdir_p(File.join(source, "_layouts"))
      FileUtils.mkdir_p(File.join(source, "_includes"))
      FileUtils.mkdir_p(File.join(source, "_projects"))

      FileUtils.cp(ROOT.join("_layouts", "about.liquid"), File.join(source, "_layouts", "about.liquid"))
      FileUtils.cp(ROOT.join("_includes", "project_highlights.liquid"), File.join(source, "_includes", "project_highlights.liquid"))

      File.write(File.join(source, "_config.yml"), <<~YAML)
        collections:
          projects:
            output: false
        baseurl: /al-folio
        url: https://example.com
      YAML
      File.write(File.join(source, "_layouts", "default.liquid"), "<!doctype html><body>{{ content }}</body>\n")
      File.write(File.join(source, "_includes", "figure.liquid"), <<~LIQUID)
        <figure data-path="{{ include.path }}" data-sizes="{{ include.sizes }}" data-class="{{ include.class }}" data-zoomable="{{ include.zoomable }}" data-avoid-scaling="{{ include.avoid_scaling }}" data-alt="{{ include.alt }}"></figure>
      LIQUID
      File.write(File.join(source, "_includes", "selected_papers.liquid"), "<div class=\"selected-publication\">selected publication</div>\n")

      write_project(source, "alpha", "Alpha Project", "alpha tagline", "2025-05-01", true, "assets/img/alpha.png")
      write_project(source, "beta", "Beta Project", "beta tagline", "2026-05-01", true, "assets/img/beta.png")
      write_project(source, "gamma", "Gamma Project", "gamma tagline", "2027-05-01", false, "assets/img/gamma.png")
      write_project(source, "delta", "Delta Project", "delta tagline", "2028-05-01", :omitted, "assets/img/delta.png")

      flag = "project_highlights: #{project_highlights}\n" unless project_highlights == :omitted
      File.write(File.join(source, "index.md"), <<~MARKDOWN)
        ---
        layout: about
        title: About
        permalink: /
        selected_papers: true
        #{flag}---
        Biography.
      MARKDOWN

      config = Jekyll.configuration(
        "source" => source,
        "destination" => destination,
        "quiet" => true,
        "trace" => true,
      )
      Jekyll::Site.new(config).process
      File.read(File.join(destination, "index.html"), encoding: "UTF-8")
    end
  end

  def write_project(source, slug, title, tagline, date, highlight, image)
    highlight_line = "highlight: #{highlight}\n" unless highlight == :omitted
    File.write(File.join(source, "_projects", "#{slug}.md"), <<~MARKDOWN)
      ---
      layout: page
      title: #{title}
      date: #{date}
      #{highlight_line}img: #{image}
      tagline: #{tagline}
      ---
    MARKDOWN
  end

  def test_highlighted_projects_are_discovered_and_sorted_newest_first
    html = render_page(project_highlights: true)

    assert_match(/<h2>\s*project highlights\s*<\/h2>/, html)
    refute_includes html, 'href="/al-folio/projects/"'
    assert_operator html.index("Beta Project"), :<, html.index("Alpha Project")
    assert_includes html, "beta tagline"
    refute_includes html, "Gamma Project"
    refute_includes html, "Delta Project"
    assert_includes html, 'data-path="assets/img/beta.png"'
    assert_includes html, 'data-sizes="200px"'
    assert_includes html, 'data-class="preview z-depth-1 rounded"'
    assert_includes html, 'data-zoomable="true"'
    assert_includes html, 'data-avoid-scaling="true"'
  end

  def test_project_highlights_are_before_selected_publications
    html = render_page(project_highlights: true)

    assert_operator html.index("Beta Project"), :<, html.index("selected publication")
  end

  def test_absent_or_false_project_highlights_hides_the_section
    [:omitted, false].each do |flag|
      html = render_page(project_highlights: flag)

      refute_includes html, "project highlights"
      refute_includes html, "Beta Project"
      assert_includes html, "selected publication"
    end
  end
end
