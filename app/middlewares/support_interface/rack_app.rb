module SupportInterface
  class RackApp
    def initialize(app)
      @app = app
    end

    def call(env)
      support_user = if FeatureFlag.active?(:dsi_stateful_session)
                       request = ActionDispatch::Request.new(env)
                       DsiSession.find_by(
                         'id = ? AND updated_at > ? AND user_type = ?',
                         request.cookie_jar.signed[:support_session_id],
                         2.hours.ago,
                         'SupportUser',
                       )
                     else
                       request = Rack::Request.new(env)
                       SupportUser.load_from_session(request.session)
                     end

      if support_user
        @app.call(env)
      else
        request.session['post_dfe_sign_in_path'] = request.fullpath
        [302, { 'Location' => '/support/sign-in' }, ['Redirecting to support sign-in...']]
      end
    end
  end
end
