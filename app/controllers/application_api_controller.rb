class ApplicationAPIController < ActionController::API
  include EmitRequestEvents
  include RequestQueryParams
  include RemoveBrowserOnlyHeaders

  rescue_from ActionController::ParameterMissing, with: :parameter_missing
  rescue_from ParameterInvalid, with: :parameter_invalid

  def parameter_missing(e)
    error_message = e.message.split("\n").first
    render json: { errors: [{ error: 'ParameterMissing', message: error_message }] }, status: :unprocessable_entity
  end

  def parameter_invalid(e)
    render json: { errors: [{ error: 'ParameterInvalid', message: e }] }, status: :unprocessable_entity
  end
end
