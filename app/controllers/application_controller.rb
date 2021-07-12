class ApplicationController < ActionController::Base
  include RequestQueryParams
  include EmitRequestEvents

  def current_user; end

  # Makes PG::QueryCanceled statement timeout errors appear in Skylight
  # against the controller action that triggered them
  # instead of bundling them with every other ErrorsController#internal_server_error
  rescue_from ActiveRecord::QueryCanceled, with: lambda {
    render template: 'errors/internal_server_error', status: :internal_server_error
  }

  def track_validation_error(form)
    ValidationError.create!(
      form_object: form.class.name,
      request_path: request.path,
      user: current_user,
      details: form.errors.messages.map { |field, messages| [field, { messages: messages, value: (form.public_send(field) if form.respond_to?(field)) }] }.to_h,
      service: service_key,
    )
  rescue StandardError => e
    # Never crash validation error tracking
    Sentry.capture_exception(e)
  end

  def render_404
    render 'errors/not_found', status: :not_found
  end

  def render_403
    render 'errors/forbidden', status: :forbidden
  end

private

  def append_info_to_payload(payload)
    super

    payload.merge!(request_query_params)
  end
end
