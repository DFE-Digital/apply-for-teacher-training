module APIDocs
  module VendorAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(VendorAPISpecification.new.as_hash)
      end

      def future_reference
        @api_reference = APIReference.new(VendorAPISpecification.new(version: '1.1').as_hash)
      end
    end
  end
end
