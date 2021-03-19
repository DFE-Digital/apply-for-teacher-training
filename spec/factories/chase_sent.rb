FactoryBot.define do
  factory :chaser_sent do
    association :chased, factory: :candidate
    chaser_type { :reference_request }
  end
end
