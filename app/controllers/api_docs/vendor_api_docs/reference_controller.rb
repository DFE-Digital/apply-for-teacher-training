module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      include VersioningHelpers

      def reference
        @api_reference = APIReference.new(VendorAPISpecification.new(version: api_version).as_hash, version: api_version)

        @references_for_other_versions = VendorAPI::VERSIONS.keys.map do |version|
          APIReference.new(VendorAPISpecification.new(version: version).as_hash, version: version)
        end
      end

      def draft
        return redirect_to api_docs_reference_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        draft_version = VendorAPISpecification::DRAFT_VERSION
        @api_reference = APIReference.new(VendorAPISpecification.new(version: draft_version).as_hash, version: draft_version, highlight_yaml_file: "config/vendor_api/v#{draft_version}-highlights.yml")
      end

      def api_version
        return VendorAPISpecification::CURRENT_VERSION unless params.key?(:api_version)

        extract_version(params[:api_version])
      end
    end
  end
end
