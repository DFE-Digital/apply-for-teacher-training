class DsiSession < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :impersonated_provider_user, class_name: 'ProviderUser', optional: true

  def provider_user
    user if user_type == 'ProviderUser'
  end

  def support_user
    user if user_type == 'SupportUser'
  end
end
