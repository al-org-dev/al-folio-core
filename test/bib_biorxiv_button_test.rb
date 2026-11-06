# frozen_string_literal: true

require_relative "test_helper"
require "liquid"

# A `biorxiv` field in a .bib entry renders a "bioRxiv" button, the same way `arxiv`
# renders an "arXiv" button. The value is the preprint DOI, which doi.org resolves to the
# latest version of the preprint.
class BibBiorxivButtonTest < Minitest::Test
  BIB = File.read(ROOT.join("_layouts", "bib.liquid").to_s, encoding: "UTF-8")

  OPENING = "{% if entry.biorxiv %}"

  # Slice the `{% if entry.biorxiv %}` … `{% endif %}` block out of the layout so it can be
  # rendered on its own: the rest of the layout uses Jekyll-only tags that core Liquid
  # cannot parse.
  def self.extract_block(source, opening)
    start = source.index(opening) or raise "#{opening} not found in template"
    finish = source.index("{% endif %}", start) or raise "unterminated #{opening}"
    source[start...(finish + "{% endif %}".length)]
  end

  BLOCK = extract_block(BIB, OPENING)

  def render_button(entry)
    Liquid::Template.parse(BLOCK).render({ "entry" => entry })
  end

  def test_biorxiv_field_renders_a_button_linking_to_the_doi
    out = render_button({ "biorxiv" => "10.64898/2026.04.12.718028" })

    assert_includes out, 'href="https://doi.org/10.64898/2026.04.12.718028"'
    assert_includes out, ">bioRxiv</a>"
    assert_includes out, 'class="btn btn-sm z-depth-0"'
  end

  def test_no_button_without_a_biorxiv_field
    assert_equal "", render_button({ "arxiv" => "2401.00001" }).strip
  end

  def test_biorxiv_button_follows_the_arxiv_button
    arxiv = BIB.index("{% if entry.arxiv %}")
    biorxiv = BIB.index(OPENING)

    assert_operator arxiv, :<, biorxiv
  end
end
