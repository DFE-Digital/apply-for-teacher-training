FactoryBot.define do
  factory :dfe_sign_in_user do
    dfe_sign_in_uid { SecureRandom.uuid }
    email_address { "#{Faker::Name.first_name.downcase}-#{SecureRandom.hex}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    initialize_with do
      new(dfe_sign_in_uid:,
          email_address:,
          first_name:,
          last_name:)
    end
  end
end
