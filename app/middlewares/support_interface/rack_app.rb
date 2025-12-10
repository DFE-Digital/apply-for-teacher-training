module SupportInterface
  class RackApp
    def initialize(app)
      @app = app
    end

    def call(env)
      # This needs to work with the DB sessions as well
      # mount SupportInterface::RackApp.new(Sidekiq::Web) => '/sidekiq', as: :sidekiq
      # mount SupportInterface::RackApp.new(Blazer::Engine) => '/blazer', as: :blazer
      # mount SupportInterface::RackApp.new(FieldTest::Engine) => '/field-test', as: :field_test
      #
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
