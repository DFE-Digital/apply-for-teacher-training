module APIDocs
  class OpenapiController < APIDocsController
    def spec
      render plain: VendorAPISpecification.as_yaml, content_type: 'text/yaml'
    end
  end
end
