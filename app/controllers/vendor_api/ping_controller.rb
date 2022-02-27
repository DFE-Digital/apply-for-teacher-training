module VendorAPI
  class PingController < VendorAPIController
    skip_before_action :validate_metadata!

    def ping
      render json: { data: 'pong' }
    end
  end
end
