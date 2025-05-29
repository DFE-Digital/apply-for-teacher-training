module ServiceAPIUserAuthentication
  include ActionController::HttpAuthentication::Token::ControllerMethods
  extend ActiveSupport::Concern

  included do
    before_action :verify_token!
  end

  def verify_token!
    unless authorized?
      render_error(
        name: 'Unauthorized',
        message: 'Please provide a valid API token',
        status: :unauthorized,
      )
    end
  end

  def authorized?
    authenticate_with_http_token do |token|
      @authenticating_token = AuthenticationToken.find_by_hashed_token(user_type: 'ServiceAPIUser', raw_token: token)
      return false if @authenticating_token.nil?

      if ServiceAPIUser.find_by(authorized_api: self.class.name.deconstantize, id: @authenticating_token.user_id)
        @authenticating_token.touch(:used_at)
        return true
      end
      false
    end
  end

  def render_error(name:, message:, status:)
    response = { errors: [{ error: name, message: }] }

    render json: response, status:
  end
end
