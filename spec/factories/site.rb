FactoryBot.define do
  factory :site do
    provider

    initialize_with { Site.find_or_initialize_by(provider:, uuid:) }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 5).upcase }
    name { "#{Faker::Educator.secondary_school} #{rand(100..999)}" }
    uuid { SecureRandom.uuid }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.city }
    address_line3 { Faker::Address.county }
    address_line4 { '' }
    region { 'north_west' }
    postcode { Faker::Address.postcode }
  end

  trait :with_coordinates do
    latitude { 51.5245592 }
    longitude { -0.1340401 }
  end
end
