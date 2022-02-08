FactoryBot.define do
  factory :interview do
    application_choice

    date_and_time { 7.business_days.from_now }
    location { [Faker::Address.full_address, 'Link to video conference'].sample }
    additional_details { [nil, 'Use staff entrance', 'Ask for John at the reception'].sample }

    transient do
      skip_application_choice_status_update { false }
    end

    after(:build) do |interview, evaluator|
      interview.application_choice.status = 'interviewing' unless evaluator.skip_application_choice_status_update
      interview.provider ||= interview.application_choice.current_provider
    end

    trait :future_date_and_time do
      date_and_time { (1...10).to_a.sample.business_days.from_now + (0..8).to_a.sample.hours }
    end

    trait :past_date_and_time do
      date_and_time { (2...10).to_a.sample.business_days.ago - (0..8).to_a.sample.hours }
    end
  end

  trait :cancelled do
    cancelled_at { 1.day.ago }
    cancellation_reason { Faker::Lorem.paragraph(sentence_count: 2) }
  end
end
