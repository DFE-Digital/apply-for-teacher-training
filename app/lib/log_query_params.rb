module LogQueryParams
  def log_query_params
    parameters = request.query_parameters.except(*SANITIZED_REQUEST_PARAMS)
    parameters.merge! request.path_parameters # e.g. /support/courses/:course_id

    parameters
  end
end
