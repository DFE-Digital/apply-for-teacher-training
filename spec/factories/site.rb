FactoryBot.define do
  factory :site, class: 'TempSite' do
    provider

    initialize_with { TempSite.find_or_initialize_by(provider: provider, code: code) }
    code { Faker::Alphanumeric.unique.alphanumeric(number: 5).upcase }
    name { "#{Faker::Educator.secondary_school} #{rand(100..999)}" }
    uuid { Faker::Internet.uuid }
    address_line1 { Faker::Address.street_address }
    address_line2 { Faker::Address.city }
    address_line3 { Faker::Address.county }
    address_line4 { '' }
    region { 'north_west' }
    postcode { Faker::Address.postcode }
  end
end
