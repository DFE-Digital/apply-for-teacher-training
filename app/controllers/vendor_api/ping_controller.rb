module VendorAPI
  class PingController < VendorAPIController
    VERSION = '1.0'.freeze

    def ping
      render json: { data: 'pong' }
    end
  end
end
