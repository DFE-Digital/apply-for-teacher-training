FactoryBot.define do
  factory :note do
    application_choice
    provider_user
    user { [0, 1].sample.zero? ? create(:vendor_api_user) : create(:provider_user) }

    message { Faker::Quote.most_interesting_man_in_the_world }
  end
end
