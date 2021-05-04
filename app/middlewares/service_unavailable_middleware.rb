class ServiceUnavailableMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @request = Rack::Request.new(env)
    if FeatureFlag.active?(:service_unavailable_page) && !monitoring_paths?
      [503, { 'Content-Type' => content_type }, [body]]
    else
      @app.call(env)
    end
  end

private

  def content_type
    return 'application/json' if api_path?

    'text/html'
  end

  def body
    return 'Service Unavailable' if api_path?

    action_view.render(template: 'errors/service_unavailable', layout: 'layouts/error')
  end

  def lookup_context
    @lookup_context ||= ActionView::LookupContext.new(ActionController::Base.view_paths)
  end

  def action_view
    @action_view ||= ActionView::Base.with_empty_template_cache.new(lookup_context, {}, ActionController::Base.new)
  end

  def api_path?
    @request.path =~ /^\/api\/.*$/
  end

  def monitoring_paths?
    @request.path =~ /^\/check$/ || @request.path =~ /^\/integrations\/monitoring\/.*$/
  end
end
