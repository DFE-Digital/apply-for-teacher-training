class ProviderRelationshipPermissions < ApplicationRecord
  belongs_to :ratifying_provider, class_name: 'Provider'
  belongs_to :training_provider, class_name: 'Provider'

  PERMISSIONS = %i[make_decisions view_safeguarding_information].freeze

  validate :at_least_one_active_permission_in_pair, if: -> { setup_at.present? }
  audited associated_with: :training_provider

  def training_provider_can_view_applications_only?
    PERMISSIONS.map { |permission| send("training_provider_can_#{permission}") }.all?(false)
  end

  def ratifying_provider_can_view_applications_only?
    PERMISSIONS.map { |permission| send("ratifying_provider_can_#{permission}") }.all?(false)
  end

private

  def at_least_one_active_permission_in_pair
    PERMISSIONS.each do |permission|
      if !send("training_provider_can_#{permission}") && !send("ratifying_provider_can_#{permission}")
        errors.add(permission, "Select which organisations can #{permission.to_s.humanize.downcase}")
      end
    end
  end
end
