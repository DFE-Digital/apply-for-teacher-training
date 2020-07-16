class ProviderRelationshipPermissions < ApplicationRecord
  belongs_to :ratifying_provider, class_name: 'Provider'
  belongs_to :training_provider, class_name: 'Provider'

  # For ease of use in views, this struct acts like a ProviderPermissions model
  PermissionsSet = Struct.new(:make_decisions?, :view_safeguarding_information?) do
    def view_applications_only?
      values.all?(&:!)
    end
  end

  def ratifying_provider_permissions
    PermissionsSet.new(
      ratifying_provider_can_make_decisions,
      ratifying_provider_can_view_safeguarding_information,
    )
  end

  def training_provider_permissions
    PermissionsSet.new(
      training_provider_can_make_decisions,
      training_provider_can_view_safeguarding_information,
    )
  end
end
