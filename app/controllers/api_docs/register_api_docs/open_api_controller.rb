module APIDocs
  module RegisterAPIDocs
    class OpenAPIController < APIDocsController
      def spec
        render plain: RegisterAPISpecification.as_yaml, content_type: 'text/yaml'
      end
    end
  end
end
