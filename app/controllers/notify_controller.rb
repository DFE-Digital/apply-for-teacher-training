class NotifyController < ApplicationController
  include ActionController::HttpAuthentication::Token::ControllerMethods

  skip_before_action :verify_authenticity_token

  rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

  def callback
    return render_unauthorized unless authorized?

    process_notify_callback = ProcessNotifyCallback.new(notify_reference: params.fetch(:reference), status: params.fetch(:status))

    response = process_notify_callback.call

    if response == :not_found
      render_not_found
    else
      render json: nil, status: :ok
    end
  end

private

  def authorized?
    authenticate_with_http_token { |token| token == ENV.fetch('GOVUK_NOTIFY_CALLBACK_API_KEY') }
  end

  def render_unauthorized
    render_error(
      name: 'Unauthorized',
      message: 'Please provide a valid authentication token',
      status: :unauthorized,
    )
  end

  def render_unprocessable_entity(e)
    render_error(
      name: 'UnprocessableEntity',
      message: e.message,
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

  def render_error(name:, message:, status:)
    response = { errors: [{ error: name, message: message }] }

    render json: response, status: status
  end
end
