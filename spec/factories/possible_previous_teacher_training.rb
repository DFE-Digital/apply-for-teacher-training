FactoryBot.define do
  factory :possible_previous_teacher_training do
    candidate
    provider_name { Faker::University.name }
    started_on { 2.years.ago }
    ended_on { 1.year.ago }
  end
end
