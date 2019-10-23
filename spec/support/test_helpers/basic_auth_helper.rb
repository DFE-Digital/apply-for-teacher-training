module TestHelpers
  module BasicAuthHelper
    def require_and_config_basic_auth
      stub_const(
        'BASIC_AUTH',
        BASIC_AUTH.merge(ui_auth: { enabled: true, username: 'basic', password: 'auth' }),
      )
    end

    def basic_auth_headers(user, password)
      { 'HTTP_AUTHORIZATION' => \
           ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
    end
  end
end
