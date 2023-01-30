FactoryBot.define do
  factory :provider do
    code { Faker::Alphanumeric.unique.alphanumeric(number: 3).upcase }
    name { Faker::University.name }
    region_code { 'london' }

    transient do
      user { nil }
    end

    provider_agreements do
      # Note that removing this line will cause unexpected validation errors
      # because we need to call `provider_permissions` to make sure that `user`
      # has been added to the list of provider permissions before trying
      # to create the provider agreement.
      #
      # If you remove this you will need to handle that some other way.
      raise "Provider does not have user `#{user.id}`" if user && !provider_permissions.map(&:provider_user).include?(user)

      [
        association(:provider_agreement,
          provider: instance,
          provider_user: user || provider_permissions.first.provider_user),
      ]
    end

    provider_permissions do
      attrs = {
        provider: instance,
      }

      attrs[:provider_user] = user if user

      [association(:provider_permissions, **attrs)]
    end

    trait :unsigned do
      provider_agreements { [] }
    end

    trait :no_users do
      unsigned # Cannot have agreements without users
      provider_permissions { [] }
    end

    trait :with_vendor do
      before(:create) do |provider|
        provider.vendor = Vendor.find_or_create_by(name: 'in_house')
      end
    end

    trait :with_api_token do
      vendor_api_tokens { [build(:vendor_api_token, provider: instance)] }
    end
  end
end
