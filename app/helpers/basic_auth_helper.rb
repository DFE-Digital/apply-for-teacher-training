module BasicAuthHelper
  def blanket_basic_auth
    if FEATURES.dig(:basic_auth, :enabled)
      authenticate_or_request_with_http_basic do |username, password|
        basic_auth_check = username == FEATURES.dig(:basic_auth, :username) && \
                           password == FEATURES.dig(:basic_auth, :password)
        support_auth_check = username == FEATURES.dig(:support_auth, :username) && \
                             password == FEATURES.dig(:support_auth, :password)
        basic_auth_check || support_auth_check
      end
    end
  end
end
