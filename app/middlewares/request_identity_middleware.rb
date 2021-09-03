class RequestIdentityMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    RequestLocals.store[:request_id] = env.fetch('action_dispatch.request_id')
    @app.call(env)
  end
end
