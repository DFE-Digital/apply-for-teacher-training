class ContentController < ApplicationController
  def accessibility
    render_content_page :accessibility
  end

  def terms_candidate
    render_content_page :terms_candidate
  end

private

  def render_content_page(page_name)
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)

    @converted_markdown = markdown.render(File.read("app/views/content/#{page_name}.md")).html_safe
    @page_name = page_name
    render 'rendered_markdown_template'
  end
end
