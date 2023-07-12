module SupportInterface
  class RackApp
    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)

      if SupportUser.load_from_session(request.session)
        @app.call(env)
      else
        request.session['post_dfe_sign_in_path'] = request.fullpath
        [302, { 'Location' => '/support/sign-in' }, ['Redirecting to support sign-in...']]
      end
    end
  end
end
