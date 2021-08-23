VENDOR_API_MAX_REQS_PER_MINUTE = 120

class Rack::Attack
  class Request < ::Rack::Request
    def remote_ip
      # This will always be present because the ActionDispatch::RemoteIp
      # middleware runs long before this middleware. Use #fetch here
      # so that we bail quickly if that middleware goes away or changes
      # the field name. Have preferred this to instantiating a whole
      # ActionDispatch::Request as that's a whole lot of work and this happens
      # on every request
      @remote_ip ||= env.fetch('action_dispatch.remote_ip')
    end
  end

  throttle('vendor_api/ip', limit: VENDOR_API_MAX_REQS_PER_MINUTE, period: 1.minute) do |req|
    req.remote_ip if req.path.match(/api\/v1/)
  end
end
