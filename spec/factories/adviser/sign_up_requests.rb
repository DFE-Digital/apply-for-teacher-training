FactoryBot.define do
  factory :adviser_sign_up_request, class: 'Adviser::SignUpRequest' do
    application_form factory: %i[application_form]
    teaching_subject factory: %i[adviser_teaching_subject]
  end
end
