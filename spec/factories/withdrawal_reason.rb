FactoryBot.define do
  factory :withdrawal_reason, class: 'WithdrawalReason' do
    application_choice
    reason { 'applying-to-another-provider.accepted_another-offer' }

    trait :published do
      status { 'published' }
    end

    trait :draft do
      status { 'draft' }
    end
  end
end
