FactoryBot.define do
  factory :english_proficiency do
    application_form
    qualification_status { 'no_qualification' }

    trait :no_qualification do
      qualification_status { 'no_qualification' }
    end

    trait :with_ielts_qualification do
      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:ielts_qualification,
                                                         english_proficiency: english_proficiency)
        english_proficiency.qualification_status = 'has_qualification'
      end
    end

    trait :with_toefl_qualification do
      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:toefl_qualification,
                                                         english_proficiency: english_proficiency)
        english_proficiency.qualification_status = 'has_qualification'
      end
    end

    trait :with_other_efl_qualification do
      after(:build) do |english_proficiency|
        english_proficiency.efl_qualification ||= create(:other_efl_qualification,
                                                         english_proficiency: english_proficiency)
        english_proficiency.qualification_status = 'has_qualification'
      end
    end

    trait :qualification_not_needed do
      qualification_status { 'qualification_not_needed' }
    end
  end
end
