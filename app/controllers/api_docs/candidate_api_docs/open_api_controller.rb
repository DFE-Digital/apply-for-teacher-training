module APIDocs
  module CandidateAPIDocs
    class OpenAPIController < APIDocsController
      def spec
        render plain: CandidateAPISpecification.as_yaml(version_param), content_type: 'text/yaml'
      end

    private

      def version_param
        params[:api_version] || CandidateAPISpecification::CURRENT_VERSION
      end
    end
  end
end
