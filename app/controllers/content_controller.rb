class ContentController < ApplicationController
  def accessibility
    render_content_page :accessibility
  end

  def terms_candidate
    render_content_page :terms_candidate
  end

  def privacy_candidate
    render_content_page :privacy_candidate
  end

  def cookies_candidate
    render_content_page :cookies_candidate
  end

private

  def render_content_page(page_name)
    @converted_markdown = Govuk::MarkdownRenderer.render(File.read("app/views/content/#{page_name}.md")).html_safe
    @page_name = page_name
    render 'rendered_markdown_template'
  end
end
