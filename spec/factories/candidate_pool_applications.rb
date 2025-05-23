FactoryBot.define do
  factory :candidate_pool_application do
    application_form { association(:application_form) }
    candidate { application_form.candidate }
  end
end
