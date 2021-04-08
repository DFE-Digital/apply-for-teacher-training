module APIDocs
  module RegisterAPIDocs
    class PagesController < APIDocsController
      def release_notes
        render_content_page :release_notes
      end

    private

      def render_content_page(page_name)
        @converted_markdown = GovukMarkdown.render(File.read("app/views/api_docs/register_api_docs/pages/#{page_name}.md")).html_safe
        @page_name = page_name

        render 'rendered_markdown_template'
      end
    end
  end
end
