FactoryBot.define do
  factory :english_proficiency do
    application_form
    draft { false }
    has_qualification { false }
    qualification_not_needed { false }
    degree_taught_in_english { false }
    no_qualification { true }
    no_qualification_details { nil }

    trait :draft do
      draft { true }
    end

    trait :no_qualification do
      has_qualification { false }
      qualification_not_needed { false }
      degree_taught_in_english { false }
      no_qualification { true }
    end

    trait :degree_taught_in_english do
      has_qualification { false }
      qualification_not_needed { false }
      degree_taught_in_english { true }
      no_qualification { false }
    end

    trait :with_ielts_qualification do
      has_qualification { true }
      qualification_not_needed { false }
      degree_taught_in_english { false }
      no_qualification { false }

      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:ielts_qualification,
                                                         english_proficiency:)
      end
    end

    trait :with_toefl_qualification do
      has_qualification { true }
      qualification_not_needed { false }
      degree_taught_in_english { false }
      no_qualification { false }

      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:toefl_qualification,
                                                         english_proficiency:)
      end
    end

    trait :with_other_efl_qualification do
      has_qualification { true }
      qualification_not_needed { false }
      degree_taught_in_english { false }
      no_qualification { false }

      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:other_efl_qualification,
                                                         english_proficiency:)
      end
    end

    trait :qualification_not_needed do
      has_qualification { false }
      qualification_not_needed { true }
      degree_taught_in_english { false }
      no_qualification { false }
    end
  end
end
