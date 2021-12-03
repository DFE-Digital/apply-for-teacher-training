module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(VendorAPISpecification.new.as_hash, version: VendorAPISpecification::CURRENT_VERSION)
      end

      def draft
        return redirect_to api_docs_reference_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        draft_version = VendorAPISpecification::DRAFT_VERSION
        @api_reference = APIReference.new(VendorAPISpecification.new(version: draft_version).as_hash, version: draft_version, highlight_yaml_file: "config/vendor_api/v#{draft_version}-highlights.yml")
      end
    end
  end
end
