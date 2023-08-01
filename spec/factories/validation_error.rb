FactoryBot.define do
  factory :validation_error do
    form_object { 'RefereeInterface::ReferenceFeedbackForm' }
    details { { feedback: { messages: ['Enter feedback'], value: '' } } }
    user factory: %i[candidate]
    request_path { '/candidate' }
    service { 'apply' }
  end
end
