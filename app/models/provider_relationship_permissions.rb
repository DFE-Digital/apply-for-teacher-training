class ProviderRelationshipPermissions < ApplicationRecord
  belongs_to :ratifying_provider, class_name: 'Provider'
  belongs_to :training_provider, class_name: 'Provider'

  PERMISSIONS = %w[make_decisions view_safeguarding_information].freeze

  def training_provider_can_view_applications_only?
    PERMISSIONS.map { |permission| send("training_provider_can_#{permission}") }.all?(false)
  end

  def ratifying_provider_can_view_applications_only?
    PERMISSIONS.map { |permission| send("ratifying_provider_can_#{permission}") }.all?(false)
  end
end
