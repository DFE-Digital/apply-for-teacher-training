module APIDocs
  module CandidateAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(CandidateAPISpecification.as_hash)
      end
    end
  end
end
