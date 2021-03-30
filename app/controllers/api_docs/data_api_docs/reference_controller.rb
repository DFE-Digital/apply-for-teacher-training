module APIDocs
  module DataAPIDocs
    class ReferenceController < APIDocsController
      def reference
        spec = DataAPISpecification.as_hash

        @api_reference = APIReference.new(spec)
      end
    end
  end
end
