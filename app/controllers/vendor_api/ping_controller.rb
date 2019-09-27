module VendorApi
  class PingController < VendorApiController
    def ping
      render json: { data: "pong" }
    end
  end
end
