FactoryBot.define do
  factory :chaser_sent do
    chased factory: %i[candidate]
    chaser_type { :reference_request }
  end
end
