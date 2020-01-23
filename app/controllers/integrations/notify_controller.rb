module Integrations
  class NotifyController < IntegrationsController
    rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

    def callback
      return render_unauthorized unless authorized?
      return render_unprocessable_entity if params.fetch(:status).nil?
      return render json: nil, status: :ok if params.fetch(:reference).nil?

      process_notify_callback = ProcessNotifyCallback.new(notify_reference: params.fetch(:reference), status: params.fetch(:status))

      process_notify_callback.call

      if process_notify_callback.not_found?
        render_not_found
      else
        render json: nil, status: :ok
      end
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
  end
end
