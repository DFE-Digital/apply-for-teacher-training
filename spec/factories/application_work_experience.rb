FactoryBot.define do
  factory :application_work_experience do
    organisation { Faker::Educator.secondary_school }
    role { ['Teacher', 'Teaching Assistant'].sample }
    commitment { %w[full_time part_time].sample }
    start_date { Faker::Date.between(from: 20.years.ago, to: 5.years.ago) }
    start_date_unknown { [true, false].sample }
    end_date { [Faker::Date.between(from: 4.years.ago, to: Time.zone.today), nil].sample }
    end_date_unknown { [true, false].sample }
    currently_working { false }
    relevant_skills { true }
    details { 'I used skills relevant to teaching in this job.' }
  end

  trait :deprecated do
    role { ['Teacher', 'Teaching Assistant'].sample }
    organisation { Faker::Educator.secondary_school }
    details { Faker::Lorem.paragraph_by_chars(number: 300) }
    working_with_children { [true, true, true, false].sample }
    start_date { Faker::Date.between(from: 20.years.ago, to: 5.years.ago) }
    end_date { [Faker::Date.between(from: 4.years.ago, to: Time.zone.today), nil].sample }
    commitment { %w[full_time part_time].sample }
    working_pattern { Faker::Lorem.paragraph_by_chars(number: 30) }
    start_date_unknown { nil }
    end_date_unknown { nil }
    relevant_skills { nil }
  end
end
