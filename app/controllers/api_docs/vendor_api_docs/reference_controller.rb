module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(VendorAPISpecification.as_hash)
      end
    end
  end
end
