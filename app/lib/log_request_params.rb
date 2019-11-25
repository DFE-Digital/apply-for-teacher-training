module LogRequestParams
  IGNORE_PARAMS = [
    /^authenticity_token$/,
    /^candidate_interface_.+_form$/,
  ].freeze

  def self.included(base)
    base.class_eval do
      before_action :add_params_to_request_store
    end
  end

  def add_params_to_request_store
    keys_to_ignore = IGNORE_PARAMS.map { |regexp| params.keys.grep(regexp) }.flatten.uniq
    RequestLocals.store[:params] = params.except(*keys_to_ignore)
  end
end
