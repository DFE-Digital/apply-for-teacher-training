FactoryBot.define do
  factory :reference_condition, class: 'ReferenceCondition' do
    offer

    text { nil }
    required { true }
    description { 'Provide 2 references' }
    status { 'pending' }
  end
end
