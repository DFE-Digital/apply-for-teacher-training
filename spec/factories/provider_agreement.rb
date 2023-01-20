FactoryBot.define do
  factory :provider_agreement do
    provider { association(:provider, :unsigned) }
    provider_user do
      provider&.provider_users&.first || association(:provider_user, providers: [provider])
    end

    agreement_type { :data_sharing_agreement }
    accept_agreement { true }
  end
end
