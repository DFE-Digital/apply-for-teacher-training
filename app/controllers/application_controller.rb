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

private

  def append_info_to_payload(payload)
    super

    payload.merge!(request_query_params)
  end
end
