FactoryBot.define do
  factory :application_feedback do
    application_form

    path { '/candidate/application/degrees' }
    page_title { Faker::Lorem.paragraph(sentence_count: 1) }
    feedback { Faker::Lorem.paragraph(sentence_count: 3) }
    consent_to_be_contacted { true }
  end
end
