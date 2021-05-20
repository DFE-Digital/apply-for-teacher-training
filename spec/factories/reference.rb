FactoryBot.define do
  factory :reference, class: 'ApplicationReference' do
    application_form
    email_address { "#{SecureRandom.hex(5)}@example.com" }
    name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
    relationship { Faker::Lorem.paragraph(sentence_count: 3) }
    referee_type { %i[academic professional school_based character].sample }
    questionnaire { nil }
    duplicate { false }
    selected { false }

    trait :not_requested_yet do
      feedback_status { 'not_requested_yet' }
      feedback { nil }
    end

    trait :feedback_refused do
      feedback_status { 'feedback_refused' }
      feedback { nil }
      requested_at { Time.zone.now - 1.day }
      feedback_refused_at { Time.zone.now }
    end

    trait :email_bounced do
      feedback_status { 'email_bounced' }
      feedback { nil }
      requested_at { Time.zone.now - 1.minute }
      email_bounced_at { Time.zone.now }
    end

    trait :cancelled do
      feedback_status { 'cancelled' }
      feedback { nil }
      requested_at { Time.zone.now - 1.day }
      cancelled_at { Time.zone.now }
    end

    trait :cancelled_at_end_of_cycle do
      feedback_status { 'cancelled_at_end_of_cycle' }
      feedback { nil }
      requested_at { Time.zone.now - 1.day }
      cancelled_at_end_of_cycle_at { Time.zone.now }
    end

    trait :feedback_requested do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now }
    end

    trait :feedback_requested_less_than_5_days_ago do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now - 2.days }
    end

    trait :feedback_requested_more_than_5_days_ago do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { Time.zone.now - 6.days }
    end

    trait :feedback_overdue do
      feedback_status { 'feedback_requested' }
      feedback { nil }
      requested_at { 11.business_days.ago }
      created_at { 11.business_days.ago }
    end

    trait :feedback_provided do
      feedback_status { 'feedback_provided' }
      feedback { Faker::Lorem.paragraph(sentence_count: 10) }
      requested_at { Time.zone.now - 1.day }
      feedback_provided_at { Time.zone.now }
      safeguarding_concerns { '' }
      relationship_correction { '' }
      selected { true }
    end

    trait :feedback_provided_with_completed_referee_questionnaire do
      feedback_status { 'feedback_provided' }
      feedback { Faker::Lorem.paragraph(sentence_count: 10) }
      requested_at { Time.zone.now }
      questionnaire do
        {
          RefereeQuestionnaire::GUIDANCE_QUESTION => "#{%w[very_poor poor ok good very_good].sample} | #{Faker::Lorem.paragraph_by_chars(number: 300)}",
          RefereeQuestionnaire::EXPERIENCE_QUESTION => "#{%w[very_poor poor ok good very_good].sample} | #{Faker::Lorem.paragraph_by_chars(number: 300)}",
          RefereeQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => "#{%w[yes no].sample} | #{Faker::PhoneNumber.cell_phone}",
          'If we asked whether a candidate was safe to work with children, would you feel able to answer?' => "#{%w[yes no].sample}| ",
        }
      end
      safeguarding_concerns { '' }
      relationship_correction { '' }
      selected { true }
    end
  end
end
