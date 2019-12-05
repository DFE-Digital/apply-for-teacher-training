module LogQueryParams
  def self.included(base)
    base.class_eval do
      before_action :add_params_to_request_store
    end
  end

  def add_params_to_request_store
    params_to_log = request.query_parameters.except(*SANITIZED_REQUEST_PARAMS)
    params_to_log.merge! request.path_parameters # e.g. /support/courses/:course_id
    RequestLocals.store[:params] = params_to_log
  end
end
