FactoryBot.define do
  factory :adviser_sign_up_request, class: 'Adviser::SignUpRequest' do
    application_form factory: %i[application_form]
    teaching_subject factory: %i[adviser_teaching_subject]

    trait :sent_to_adviser do
      sent_to_adviser_at { Time.zone.now }
    end
  end
end
