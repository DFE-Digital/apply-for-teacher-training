class ProviderPermissionsForm
  include ActiveModel::Model

  attr_accessor :active
  attr_accessor :provider_permission

  delegate :provider, :manage_users, to: :provider_permission
  delegate :id, to: :provider
end
