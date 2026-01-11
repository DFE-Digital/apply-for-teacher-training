FactoryBot.define do
  factory :dsi_session do
    user { provider_user }
    email_address { 'test@provider.com' }
  end

  trait :support_user do
    user { support_user }
    email_address { 'test@support.com' }
  end
end
