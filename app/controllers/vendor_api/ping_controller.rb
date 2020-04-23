module VendorAPI
  class PingController < VendorAPIController
    def ping
      render json: { data: 'pong' }
    end
  end
end
