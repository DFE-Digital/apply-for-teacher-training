module TestHelpers
  module BasicAuthHelper
    def basic_auth_headers(user, password)
      { 'HTTP_AUTHORIZATION' => \
           ActionController::HttpAuthentication::Basic.encode_credentials(user, password) }
    end
  end
end
