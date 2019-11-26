module SupportInterface
  class SupportInterfaceController < ActionController::Base
    include LogRequestParams

    layout 'support_layout'
    before_action :protect_with_basic_auth

  private

    def protect_with_basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        (username == ENV.fetch('SUPPORT_USERNAME')) && (password == ENV.fetch('SUPPORT_PASSWORD'))
      end
    end
  end
end
