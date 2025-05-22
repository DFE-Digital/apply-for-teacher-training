FactoryBot.define do
  factory :pool_eligible_application_form do
    application_form { association(:application_form) }
  end
end
