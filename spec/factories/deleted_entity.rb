FactoryBot.define do
  factory :deleted_entity do
    entity_id { Faker::Number.number }
    entity_name { 'candidate' }
    deleted_records { { application_forms: [1] } }
  end
end
