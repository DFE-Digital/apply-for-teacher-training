FactoryBot.define do
  factory :degree_subject_group do
    application_qualification { association(:degree_qualification) }
    name { 'Geography' }
    subject_group_uuid { '3e74e24c-656a-40f1-9bae-042213e5fb5f' }
  end
end
