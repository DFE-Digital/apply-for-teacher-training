class ProviderRelationshipPermissions < ApplicationRecord
  belongs_to :ratifying_provider, class_name: 'Provider'
  belongs_to :training_provider, class_name: 'Provider'
end
