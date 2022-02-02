module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      include VersioningHelpers

      helper_method :render_api_docs_version_navigation?
      helper_method :api_docs_version_navigation_items

      def reference
        @api_reference = APIReference.new(VendorAPISpecification.new(version: version).as_hash, version: version)
      end

      def draft
        return redirect_to api_docs_reference_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        @api_reference = APIReference.new(VendorAPISpecification.new(draft: true).as_hash, draft: true)
      end

    private

      def version
        extract_version(params[:api_version])
      end
    end
  end
end
