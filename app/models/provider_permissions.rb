class ProviderPermissions < ActiveRecord::Base
  VALID_PERMISSIONS = %i[
    manage_users
    manage_organisations
    view_safeguarding_information
    make_decisions
  ].freeze

  self.table_name = 'provider_users_providers'

  belongs_to :provider_user
  belongs_to :provider

  audited associated_with: :provider_user

  scope :manage_users, -> { where(manage_users: true) }
  scope :manage_organisations, -> { where(manage_organisations: true) }
  scope :view_safeguarding_information, -> { where(view_safeguarding_information: true) }
  scope :make_decisions, -> { where(make_decisions: true) }

  def self.possible_permissions(current_provider_user:, provider_user:)
    provider_ids = current_provider_user
      .provider_permissions
      .manage_users
      .includes(:provider)
      .order('providers.name')
      .pluck(:provider_id)

    provider_ids.map do |id|
      find_or_initialize_by(
        provider_id: id,
        provider_user_id: provider_user&.id,
      )
    end
  end

  def view_applications_only?
    VALID_PERMISSIONS.map { |permission| send(permission) }.all?(false)
  end
end
