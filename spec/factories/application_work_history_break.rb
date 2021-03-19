FactoryBot.define do
  factory :application_work_history_break do
    start_date { Faker::Date.between(from: 20.years.ago, to: 5.years.ago) }
    end_date { Faker::Date.between(from: 4.years.ago, to: Time.zone.today) }
    reason { Faker::Lorem.sentence(word_count: 400) }
  end
end
