class ProviderUsersProvider < ActiveRecord::Base
  belongs_to :provider_user
  belongs_to :provider
end
