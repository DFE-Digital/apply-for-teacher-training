class RackExceptionsApp
  def self.call(env)
    if env['REQUEST_PATH'] =~ /^\/[^\/]*api\/.*$/
      [503, { 'Content-Type' => 'text/plain' }, ['Service Unavailable']]
    else
      @body ||= action_view.render(template: 'errors/service_down', layout: 'layouts/error')
      [503, { 'Content-Type' => 'text/html' }, [@body]]
    end
  end

  def self.lookup_context
    ActionView::LookupContext.new(ActionController::Base.view_paths)
  end

  def self.action_view
    ActionView::Base.with_empty_template_cache.new(lookup_context, {}, ActionController::Base.new)
  end
end
