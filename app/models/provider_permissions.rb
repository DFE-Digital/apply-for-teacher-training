class ProviderPermissions < ActiveRecord::Base
  VALID_PERMISSIONS = %i[manage_users].freeze

  self.table_name = 'provider_users_providers'

  belongs_to :provider_user
  belongs_to :provider

  audited associated_with: :provider_user

  scope :manage_users, -> { where(manage_users: true) }
end
