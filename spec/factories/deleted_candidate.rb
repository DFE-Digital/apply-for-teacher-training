FactoryBot.define do
  factory :deleted_candidate do
    candidate_id { Faker::Number.number }
    deleted_tables { { application_forms: [1] } }
  end
end
