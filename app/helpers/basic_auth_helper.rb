module BasicAuthHelper
  def require_basic_auth_for_ui
    if BasicAuth.enabled?
      ui_user = BasicAuth.get(:ui, :username)
      ui_pass = BasicAuth.get(:ui, :password)
      support_user = BasicAuth.get(:support, :username)
      support_pass = BasicAuth.get(:support, :password)

      raise 'missing BASIC_AUTH_USERNAME/BASIC_AUTH_PASSWORD' if
        ui_user.blank? || ui_pass.blank? || support_user.blank? || support_pass.blank?

      authenticate_or_request_with_http_basic do |username, password|
        basic_auth_check = (username == ui_user && password == ui_pass)
        support_auth_check = (username == support_user && password == support_pass)
        basic_auth_check || support_auth_check
      end
    end
  end
end
