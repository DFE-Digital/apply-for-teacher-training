class SandboxRateLimitingTestsController < ApplicationController
  def index
    render json: {
      data:
        {
          # To see what front door does to our headers.
          # Trying to work out if the code for
          # 'Fixing' the headers is still relevant, or if it might be breaking things.
          http_headers: request.env.select { |k, _v| k =~ /^HTTP_/ }.to_h,
          remote_ip: request.remote_ip,
          forwarded_for: request.forwarded_for,
          # I think this is what we want.
          real_ip: request.headers['x-real-ip'],
        },
    }
  end
end
