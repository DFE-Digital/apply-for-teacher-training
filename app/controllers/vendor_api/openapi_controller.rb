module VendorApi
  class OpenapiController < VendorApiController
    skip_before_action :require_valid_api_token!

    def spec
      render text: File.read('config/vendor-api-0.8.0.yml'), content_type: 'text/yaml'
    end
  end
end
