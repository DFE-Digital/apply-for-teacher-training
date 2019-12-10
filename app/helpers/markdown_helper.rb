module MarkdownHelper
  def markdown_to_html(markdown)
    Govuk::MarkdownRenderer.render(markdown.to_s).html_safe
  end
end
