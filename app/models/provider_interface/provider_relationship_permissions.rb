module ProviderInterface
  class ProviderRelationshipPermissions < ApplicationRecord
    belongs_to :ratifying_provider, class_name: 'Provider'
    belongs_to :training_provider, class_name: 'Provider'

    VALID_PERMISSIONS = %i[view_safeguarding_information].freeze

    scope :view_safeguarding_information, -> { where(view_safeguarding_information: true) }
  end
end
