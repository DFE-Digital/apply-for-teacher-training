module Apply
  class ContentSecurityPolicyMiddleware < ActionDispatch::ContentSecurityPolicy::Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if FeatureFlag.active?(:content_security_policy)
        super
      else
        @app.call(env)
      end
    end
  end
end
