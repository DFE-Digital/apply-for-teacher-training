FactoryBot.define do
  factory :previous_teacher_training do
    application_form factory: %i[application_form]
    provider
    provider_name { provider.name }
    status { 'draft' }
    started { 'yes' }
    started_at { 2.years.ago }
    ended_at { 1.year.ago }
    details { Faker::Lorem.sentence }

    trait :outside_provider do
      provider { nil }
      provider_name { Faker::University.name }
    end

    trait :not_started do
      application_form factory: %i[application_form]
      status { 'draft' }
      started { 'no' }
      provider_name { nil }
      started_at { nil }
      ended_at { nil }
      details { nil }
    end

    trait :published do
      status { 'published' }
    end
  end
end
