FactoryBot.define do
  factory :provider_user_content_template do
    provider_user { build(:provider_user) }
    kind { :invite_message }
    body { 'test template' }
  end
end
