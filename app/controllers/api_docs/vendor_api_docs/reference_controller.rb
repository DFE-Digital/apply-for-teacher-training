module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(VendorAPISpecification.new.as_hash)
      end

      def draft
        return redirect_to api_docs_reference_path unless FeatureFlag.active?(:draft_vendor_api_specification)

        @api_reference = APIReference.new(VendorAPISpecification.new(draft: true).as_hash)
      end
    end
  end
end
