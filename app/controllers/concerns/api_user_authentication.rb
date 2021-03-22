module APIUserAuthentication
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
      @authenticating_token = AuthenticationToken.find_by_hashed_token(user_type: 'APIUser', raw_token: token)
      @authenticating_token.user_id == APIUser.find_by(api_type: self.class.name.deconstantize).id
    end
  end

  def render_error(name:, message:, status:)
    response = { errors: [{ error: name, message: message }] }

    render json: response, status: status
  end
end
