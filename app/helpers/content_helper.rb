module ContentHelper
  def render_content_page(page_name)
    @converted_markdown = Govuk::MarkdownRenderer.render(File.read("app/views/content/#{page_name}.md")).html_safe
    @page_name = page_name
    @recruitment_cycle_span = "#{RecruitmentCycle.current_year} to #{RecruitmentCycle.next_year}"
    render 'rendered_markdown_template'
  end
end
