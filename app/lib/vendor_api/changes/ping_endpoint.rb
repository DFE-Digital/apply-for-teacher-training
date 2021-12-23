module VendorAPI
  module Changes
    class PingEndpoint < VersionChange
      description 'Pong'

      action PingController, :ping
    end
  end
end
