module LogRequestParams
  IGNORE_PARAMS = %w(authenticity_token).freeze

  def self.included(base)
    base.class_eval do
      before_action :add_params_to_request_store
    end
  end

  def add_params_to_request_store
    RequestLocals.store[:params] = params.except(*IGNORE_PARAMS)
  end
end
