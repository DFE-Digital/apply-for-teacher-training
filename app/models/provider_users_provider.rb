class ProviderUsersProvider < ActiveRecord::Base
  belongs_to :provider_user
  belongs_to :provider

  audited associated_with: :provider_user
end
