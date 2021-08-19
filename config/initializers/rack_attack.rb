VENDOR_API_MAX_REQS_PER_MINUTE = 120

class Rack::Attack
  throttle('vendor_api/ip', limit: VENDOR_API_MAX_REQS_PER_MINUTE, period: 1.minute) do |req|
    req.ip if req.path.match(/api\/v1/)
  end
end
