class NotifyController < ApplicationController
  skip_before_action :verify_authenticity_token

  def callback
    return render_unauthorized if unauthorized?
    return render_unprocessable_entity if reference_or_status_missing?

    response = ProcessNotifyCallback.call(notify_reference: params['reference'], status: params['status'])

    if response == :not_found
      render_not_found
    else
      render json: nil, status: :ok
    end
  end

private

  def unauthorized?
    authorization_token.nil? || authorization_token != ENV.fetch('GOVUK_NOTIFY_CALLBACK_API_KEY')
  end

  def authorization_token
    request.headers['Authorization']&.gsub('Bearer ', '')
  end

  def reference_or_status_missing?
    params['reference'].nil? || params['status'].nil?
  end

  def render_unauthorized
    render_error(
      name: 'Unauthorized',
      message: 'Please provide a valid authentication token',
      status: :unauthorized,
    )
  end

  def render_unprocessable_entity
    render_error(
      name: 'UnprocessableEntity',
      message: "A 'reference' or 'status' key was not included on the request body",
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
