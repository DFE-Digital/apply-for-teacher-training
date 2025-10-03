FactoryBot.define do
  factory :monthly_statistics_report, class: '::Publications::MonthlyStatistics::MonthlyStatisticsReport' do
    month { '2023-12' }
    generation_date { Time.zone.local(2023, 12, 18) }
    publication_date { Time.zone.local(2023, 12, 25) }

    trait :v1 do
      statistics { V1MonthlyStatisticsStubbedReport.new.to_h }
      generation_date { Time.zone.local(2023, 8, 21) }
      publication_date { Time.zone.local(2023, 8, 28) }
      month { "#{generation_date.year}-#{generation_date.month}" }
    end

    trait :v2 do
      statistics { Publications::MonthlyStatistics::StubbedReport.new.to_h }
      publication_date { 1.day.ago }
      generation_date { 8.days.ago }
      month { "#{generation_date.year}-#{generation_date.month}" }
    end
  end
end
