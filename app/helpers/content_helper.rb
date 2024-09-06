module ContentHelper
  def render_content_page(page_name, breadcrumb_title: nil, breadcrumb_path: nil, locals: {})
    render_markdown_content(
      'rendered_markdown_template',
      page_name,
      breadcrumb_title:,
      breadcrumb_path:,
      locals:,
    )
  end

  def render_deprecated_privacy_notice_pages(page_name, breadcrumb_title: nil, breadcrumb_path: nil, locals: {})
    render_markdown_content(
      'rendered_old_privacy_notices_markdown',
      page_name,
      breadcrumb_title:,
      breadcrumb_path:,
      locals:,
    )
  end

private

  def render_markdown_content(template_name, page_name, breadcrumb_title: nil, breadcrumb_path: nil, locals: {})
    raw_content = File.read("app/views/content/#{page_name}.md")
    content_with_erb_tags_replaced = ApplicationController.renderer.render(
      inline: raw_content,
      locals:,
    )
    @converted_markdown = GovukMarkdown.render(content_with_erb_tags_replaced).html_safe
    @page_name = page_name
    @breadcrumb_title = breadcrumb_title
    @breadcrumb_path = breadcrumb_path

    render template_name
  end
end
