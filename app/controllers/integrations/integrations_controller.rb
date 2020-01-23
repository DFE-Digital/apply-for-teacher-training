module Integrations
  class IntegrationsController < ActionController::API
    include ActionController::HttpAuthentication::Token::ControllerMethods

  private

    def render_error(name:, message:, status:)
      response = { errors: [{ error: name, message: message }] }

      render json: response, status: status
    end

    def render_unauthorized
      render_error(
        name: 'Unauthorized',
        message: 'Please provide a valid authentication token',
        status: :unauthorized,
      )
    end
  end
end
