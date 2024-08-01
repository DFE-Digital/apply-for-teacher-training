FactoryBot.define do
  factory :rejection_feedback do
    application_choice { association(:application_choice, :rejected) }
  end
end
