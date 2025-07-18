FactoryBot.define do
  factory :pool_decline_reason, class: 'Pool::DeclineReason' do
    reason { 'Example reason' }
    comment { 'Optional comment' }
    status { 'draft' }
    invite factory: %i[pool_invite]

    trait :draft do
      status { 'draft' }
    end

    trait :published do
      status { 'published' }
    end
  end
end
