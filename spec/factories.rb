FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex}@example.com" }
  end

  factory :application_form do
  end

  factory :application_choice do
  end
end
