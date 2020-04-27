module APIDocs
  class OpenapiController < APIDocsController
    def spec
      render plain: VendorAPI::OpenAPISpec.as_yaml, content_type: 'text/yaml'
    end
  end
end
