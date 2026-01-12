class DsiSession < ApplicationRecord
  belongs_to :user, polymorphic: true
  belongs_to :impersonated_provider_user, class_name: 'ProviderUser', optional: true
end
