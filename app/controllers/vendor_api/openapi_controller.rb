module VendorApi
  class OpenapiController < VendorApiController
    skip_before_action :require_valid_api_token!

    def spec
      render text: File.read('config/vendor-api-v1.yml'), content_type: 'text/yaml'
    end
  end
end
