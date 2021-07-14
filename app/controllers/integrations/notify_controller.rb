module Integrations
  class NotifyController < IntegrationsController
    before_action :set_context

    include ActionController::HttpAuthentication::Token::ControllerMethods

    rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

    def callback
      return render_unauthorized unless authorized?
      return render_unprocessable_entity if params.fetch(:status).nil?
      return render json: nil, status: :ok if params.fetch(:reference).nil?

      ProcessNotifyCallbackWorker.perform_async(reference_status_parameters)

      render json: nil, status: :ok
    end

  private

    def authorized?
      authenticate_with_http_token { |token| token == ENV.fetch('GOVUK_NOTIFY_CALLBACK_API_KEY') }
    end

    def render_unprocessable_entity
      render_error(
        name: 'UnprocessableEntity',
        message: "A 'reference' or 'status' key was not included or empty in the request body",
        status: :unprocessable_entity,
      )
    end

    def render_not_found
      reference_id = params['reference'].split('-').last

      render_error(
        name: 'NotFound',
        message: "Could not find a reference with ID: #{reference_id}",
        status: :not_found,
      )
    end

    def render_unauthorized
      render_error(
        name: 'Unauthorized',
        message: 'Please provide a valid authentication token',
        status: :unauthorized,
      )
    end

    def set_context
      Raven.extra_context(reference_status_parameters)
    end

    def reference_status_parameters
      params.permit(:reference, :status).to_h
    end

    def append_info_to_payload(payload)
      super

      payload.merge!(reference_status_parameters)
    end
  end
end
