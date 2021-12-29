module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      include VersioningHelpers

      helper_method :api_docs_version_navigation_items

      def reference
        @api_reference = APIReference.new(VendorAPISpecification.new(version: api_version).as_hash, version: api_version)

        @references_for_other_versions = VendorAPI::VERSIONS.keys.map do |version|
          APIReference.new(VendorAPISpecification.new(version: version).as_hash, version: version)
        end
      end

      def draft
        return redirect_to api_docs_reference_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        @api_reference = APIReference.new(
          VendorAPISpecification.new(version: VendorAPI.draft_version).as_hash,
          version: VendorAPI.draft_version,
        )
      end

      def api_version
        return VendorAPI::VERSION unless params.key?(:api_version)

        extract_version(params[:api_version])
      end
    end
  end
end
