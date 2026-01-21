FactoryBot.define do
  factory :dsi_session do
    user { create(:provider_user) }
    email_address { 'test@provider.com' }
  end

  trait :support_user do
    user { create(:support_user) }
    email_address { 'test@support.com' }
  end

  trait :support_user_impersonating_provider do
    user { create(:support_user) }
    impersonated_provider_user { create(:provider_user) }
    email_address { 'test@support.com' }
  end
end
