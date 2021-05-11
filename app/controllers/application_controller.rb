class ApplicationController < ActionController::Base
  include LogQueryParams
  include EmitRequestEvents

  def current_user; end

private

  def append_info_to_payload(payload)
    super

    payload.merge!(log_query_params)
  end
end
