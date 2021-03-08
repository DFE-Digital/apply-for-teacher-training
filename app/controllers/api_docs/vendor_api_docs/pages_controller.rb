module APIDocs
  module VendorAPIDocs
    class PagesController < APIDocsController
      def home
        render_content_page :home
      end

      def usage
        render_content_page :usage
      end

      def help
        render_content_page :help
      end

      def release_notes
        render_content_page :release_notes
      end

      def alpha_release_notes
        render_content_page :alpha_release_notes
      end

      def lifecycle; end

      def when_emails_are_sent; end

    private

      def render_content_page(page_name)
        @converted_markdown = GovukMarkdown.render(File.read("app/views/api_docs/vendor_api_docs/pages/#{page_name}.md")).html_safe
        @page_name = page_name

        render 'rendered_markdown_template'
      end
    end
  end
end
