FactoryBot.define do
  factory :application_experience do
    role { ['Teacher', 'Teaching Assistant'].sample }
    organisation { Faker::Educator.secondary_school }
    details { Faker::Lorem.paragraph_by_chars(number: 300) }
    working_with_children { [true, true, true, false].sample }
    start_date { Faker::Date.between(from: 20.years.ago, to: 5.years.ago) }
    end_date { [Faker::Date.between(from: 4.years.ago, to: Time.zone.today), nil].sample }
    commitment { %w[full_time part_time].sample }
    working_pattern { Faker::Lorem.paragraph_by_chars(number: 30) }
  end

  factory :application_volunteering_experience,
          parent: :application_experience,
          class: 'ApplicationVolunteeringExperience'

  factory :application_work_experience,
          parent: :application_experience,
          class: 'ApplicationWorkExperience'
end
