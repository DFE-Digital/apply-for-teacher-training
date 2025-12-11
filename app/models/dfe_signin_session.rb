class DfESigninSession < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :impersonated_provider_user, class_name: 'ProviderUser', optional: true

  def support_user
    user if user_type == 'SupportUser'
  end

  def provider_user
    user if user_type == 'ProviderUser'
  end
end
