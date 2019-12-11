module ApiDocs
  class OpenapiController < ApiDocsController
    def spec
      render plain: File.read('config/vendor-api-v1.yml'), content_type: 'text/yaml'
    end
  end
end
