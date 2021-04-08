module APIDocs
  module RegisterAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(RegisterAPISpecification.as_hash)
      end
    end
  end
end
