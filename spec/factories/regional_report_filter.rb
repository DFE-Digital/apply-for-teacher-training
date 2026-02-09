FactoryBot.define do
  factory :regional_report_filter do
    provider_user
    provider
    region { 'London' }
  end
end
