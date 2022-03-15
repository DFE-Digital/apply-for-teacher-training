module APIDocs
  module CandidateAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(CandidateAPISpecification.as_hash(version))
      end

    private

      def version
        params[:api_version]
      end
    end
  end
end
