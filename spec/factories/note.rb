FactoryBot.define do
  factory :note do
    application_choice
    provider_user

    subject { Faker::Company.bs.capitalize }
    message { Faker::Quote.most_interesting_man_in_the_world }
  end
end
