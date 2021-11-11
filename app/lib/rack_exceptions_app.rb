class RackExceptionsApp
  def self.call(env)
    if env['REQUEST_PATH'] =~ /^\/[^\/]*api\/.*$/
      [500, { 'Content-Type' => 'text/plain' }, ['Internal Server Error']]
    else
      @body ||= action_view.render(template: 'errors/internal_server_error', layout: 'layouts/error')
      [500, { 'Content-Type' => 'text/html' }, [@body]]
    end
  end

  def self.lookup_context
    ActionView::LookupContext.new(ActionController::Base.view_paths)
  end

  def self.action_view
    ActionView::Base.with_empty_template_cache.new(lookup_context, {}, ActionController::Base.new)
  end
end
