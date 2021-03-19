FactoryBot.define do
  factory :provider_agreement do
    provider_user
    provider

    agreement_type { :data_sharing_agreement }
    accept_agreement { true }

    after(:build) do |_agreement, evaluator|
      unless evaluator.provider.provider_users.exists?(evaluator.provider_user.id)
        evaluator.provider.provider_users << evaluator.provider_user
      end
    end
  end
end
