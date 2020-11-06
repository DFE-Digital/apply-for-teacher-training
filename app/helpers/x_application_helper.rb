# frozen_string_literal: true

module XApplicationHelper
  def markdown(source)
    render = Govuk::MarkdownRenderer
    # Options: https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
    # lax_spacing: HTML blocks do not require to be surrounded by an empty line as in the Markdown standard.
    # autolink: parse links even when they are not enclosed in <> characters
    options = { autolink: true, lax_spacing: true }
    markdown = Redcarpet::Markdown.new(render, options)

    # Fix common markdown errors:
    # - using bullets rather than *
    # - not putting a space between * and word
    source = source.gsub(/•\s?/, "* ").gsub(/^\*(?![\s\*])/, "* ")

    # Convert quotes to smart quotes
    source_with_smart_quotes = smart_quotes(source)
    markdown.render(source_with_smart_quotes).html_safe
  end

  def smart_quotes(string)
    return "" if string.blank?

    RubyPants.new(string, 2, ruby_pants_options).to_html
  end

private

  # Use characters rather than HTML entities for smart quotes this matches how
  # we write smart quotes in templates and allows us to use them in <title>
  # elements
  # https://github.com/jmcnevin/rubypants/blob/master/lib/rubypants.rb
  def ruby_pants_options
    {
      double_left_quote: "“",
      double_right_quote: "”",
      single_left_quote: "‘",
      single_right_quote: "’",
      ellipsis: "…",
      em_dash: "—",
      en_dash: "–",
    }
  end
end
