module APIDocs
  module VendorAPIDocs
    class PagesController < APIDocsController
      def home
        render_content_page :home, locals: { current_api_version:, next_api_version: }
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

    private

      def render_content_page(page_name, locals: {})
        raw_content = File.read("app/views/api_docs/vendor_api_docs/pages/#{page_name}.md")
        content_with_erb_tags_replaced = ApplicationController.renderer.render(
          inline: raw_content,
          locals:,
        )
        @converted_markdown = GovukMarkdown.render(content_with_erb_tags_replaced).html_safe
        @page_name = page_name

        render 'rendered_markdown_template'
      end

      def current_api_version
        AllowedCrossNamespaceUsage::VendorAPIInfo.production_version.to_f
      end

      def next_api_version
        (current_api_version + 0.1).round(1)
      end
    end
  end
end
