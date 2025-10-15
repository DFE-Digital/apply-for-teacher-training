FactoryBot.define do
  factory :pool_invite_decline_reason, class: 'Pool::InviteDeclineReason' do
    reason { 'Example reason' }
    comment { 'Optional comment' }
    invite factory: %i[pool_invite]
  end
end
