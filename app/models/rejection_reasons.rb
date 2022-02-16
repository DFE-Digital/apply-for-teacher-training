class RejectionReasons
  extend DynamicRejectionReasons
  include ActiveModel::Model

  initialize_dynamic_rejection_reasons
end
