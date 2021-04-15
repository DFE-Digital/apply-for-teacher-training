class RedirectToServiceGovUkMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    Rails.logger.info "Hostname is #{req.host}"
    if req_host_is_education_gov_uk(req)
      [301, { 'Location' => "#{req.scheme}://#{service_gov_uk_host(req)}#{req.fullpath}" }, self]
    else
      @app.call(env)
    end
  end

  def req_host_is_education_gov_uk(request)
    request.host.include? 'education.gov.uk'
  end

  def service_gov_uk_host(request)
    request.host.sub 'education.gov.uk', 'service.gov.uk'
  end

  def each(&block) end
end
