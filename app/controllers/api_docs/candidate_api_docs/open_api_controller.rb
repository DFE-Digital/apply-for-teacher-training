module APIDocs
  module CandidateAPIDocs
    class OpenAPIController < APIDocsController
      def spec
        render plain: CandidateAPISpecification.as_yaml, content_type: 'text/yaml'
      end
    end
  end
end
