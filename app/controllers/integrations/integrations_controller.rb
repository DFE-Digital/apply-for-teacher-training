module Integrations
  class IntegrationsController < ApplicationAPIController
  protected

    def render_error(name:, message:, status:)
      response = { errors: [{ error: name, message: }] }

      render json: response, status:
    end
  end
end
