FactoryBot.define do
  factory :provider_mid_cycle_report, class: Publications::ProviderMidCycleReport do
    provider
    statistics { [] }
    publication_date { 2.weeks.ago }
  end
end
