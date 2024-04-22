FactoryBot.define do
  factory :provider_recruitment_performance_report, class: '::Publications::ProviderRecruitmentPerformanceReport' do
    provider { association :provider }
    cycle_week { 10 }
    generation_date { Time.zone.local(2024, 6, 18) }
    publication_date { Time.zone.local(2024, 6, 25) }
    statistics { { data_to_fill_in_later: 'here' } }
  end
end
