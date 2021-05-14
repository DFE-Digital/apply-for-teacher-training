class ApplicationController < ActionController::Base
  include RequestQueryParams
  include EmitRequestEvents

  def current_user; end

private

  def append_info_to_payload(payload)
    super

    payload.merge!(request_query_params)
  end
end
