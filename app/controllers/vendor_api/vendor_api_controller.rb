module VendorApi
  class VendorApiController < ActionController::API
    before_action :set_cors_headers

  private

    def set_cors_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end
  end
end
