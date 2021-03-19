FactoryBot.define do
  factory :validation_error do
    form_object { 'RefereeInterface::ReferenceFeedbackForm' }
    details { { feedback: { messages: ['Enter feedback'], value: '' } } }
    association :user, factory: :candidate
    request_path { '/candidate' }
  end
end
