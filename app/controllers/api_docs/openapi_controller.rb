module ApiDocs
  class OpenapiController < ApiDocsController
    def spec
      render plain: VendorApi::OpenApiSpec.as_yaml, content_type: 'text/yaml'
    end
  end
end
