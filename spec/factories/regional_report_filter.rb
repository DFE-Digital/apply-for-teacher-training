FactoryBot.define do
  factory :regional_report_filter do
    provider_user
    provider
    region { 'London' }
    recruitment_cycle_year { 2026 }
  end
end
