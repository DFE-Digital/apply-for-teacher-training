FactoryBot.define do
  factory :candidate do
    email_address { "#{SecureRandom.hex}@example.com" }
  end

  factory :application_form do
    candidate
  end

  factory :application_choice do
    application_form
    status { :application_complete }
  end
end
