FactoryBot.define do
  factory :withdrawal_reason, class: 'WithdrawalReason' do
    reason { 'applying-to-another-provider.accepted_another-offer' }
  end
end
