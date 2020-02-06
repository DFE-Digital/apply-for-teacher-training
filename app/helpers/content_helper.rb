module ContentHelper
  def render_content_page(page_name)
    path_to_source = "app/views/content/#{page_name}.md"
    markdown_source = if File.exist?("#{path_to_source}.erb")
                        ERB.new(File.read("#{path_to_source}.erb")).result(binding)
                      else
                        File.read(path_to_source)
                      end
    @converted_markdown = Govuk::MarkdownRenderer.render(markdown_source).html_safe
    @page_name = page_name
    render 'rendered_markdown_template'
  end
end
