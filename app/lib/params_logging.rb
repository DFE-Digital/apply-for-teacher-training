module ParamsLogging
  IGNORE_PARAMS = %w(candidate authenticity_token).freeze

  def add_params_to_request_store
    params = request.try(:params)
    if params
      RequestLocals.store[:params] = params.except(*IGNORE_PARAMS)
    end
  end
end
