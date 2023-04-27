FactoryBot.define do
  factory :reference_condition, parent: :offer_condition, class: 'ReferenceCondition' do
    offer

    text { nil }
    required { true }
    description { 'Provide 2 references' }
  end
end
