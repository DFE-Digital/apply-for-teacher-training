module APIDocs
  module CandidateAPIDocs
    class ReferenceController < APIDocsController
      def reference
        @api_reference = APIReference.new(CandidateAPISpecification.as_hash(api_version))
      end

    private

      def api_version
        params[:api_version]
      end
    end
  end
end
