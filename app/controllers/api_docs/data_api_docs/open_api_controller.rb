module APIDocs
  module DataAPIDocs
    class OpenAPIController < APIDocsController
      def spec
        render plain: DataAPISpecification.as_yaml, content_type: 'text/yaml'
      end
    end
  end
end
