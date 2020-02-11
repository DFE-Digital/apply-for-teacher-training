module Integrations
  class IntegrationsController < ActionController::API
  protected
    def render_error(name:, message:, status:)
      response = { errors: [{ error: name, message: message }] }

      render json: response, status: status
    end
  end
end
