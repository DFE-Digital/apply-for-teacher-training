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

  trait :university_of_manchester_coordinates do
    latitude { 53.4669264 }
    longitude { -2.233578 }
    postcode { 'M13 9PL' }
  end

  trait :with_valid_coordinates do
    latitude { 51.5245592 }
    longitude { -0.1340401 } # London, UK
    postcode { 'WC1E 6AE' }
  end

  trait :with_invalid_coordinates do
    latitude { 41.5800945 }
    longitude { -71.4774291 } # Massachusetts, US
    postcode { 'Y6W 7XN' }
  end
end
