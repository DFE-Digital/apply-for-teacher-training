module ContentHelper
  def render_content_page(page_name)
    @converted_markdown = Govuk::MarkdownRenderer.render(File.read("app/views/content/#{page_name}.md")).html_safe
    @page_name = page_name
    render 'rendered_markdown_template'
  end
end
