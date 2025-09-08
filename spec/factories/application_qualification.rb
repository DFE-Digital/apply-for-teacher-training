FactoryBot.define do
  factory :application_qualification do
    application_form
    level { %w[degree gcse other].sample }
    qualification_type do
      case level
      when 'degree'
        CandidateInterface::Degrees::BaseForm::QUALIFICATION_LEVEL.keys.sample
      when 'gcse'
        CandidateInterface::OtherQualificationTypeForm::GCSE_TYPE
      when 'other'
        [
          CandidateInterface::OtherQualificationTypeForm::A_LEVEL_TYPE,
          CandidateInterface::OtherQualificationTypeForm::AS_LEVEL_TYPE,
        ].sample
      end
    end
    subject { Faker::Educator.subject }
    grade { %w[A B].sample }
    predicted_grade { %w[true false].sample }
    award_year { Faker::Date.between(from: 10.years.ago, to: 1.year.ago).year }
    institution_name { Faker::University.name }
    institution_country { international? ? Faker::Address.country_code : 'GB' }

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end

    factory :gcse_qualification do
      level { 'gcse' }
      qualification_type { 'gcse' }
      subject { %w[maths english science].sample }
      grade { %w[A B C].sample }
      predicted_grade { false }
      institution_name { nil }
      institution_country { nil }
      award_year { Faker::Date.between(from: 10.years.ago, to: 8.years.ago).year }

      trait :non_uk do
        qualification_type { 'non_uk' }
        non_uk_qualification_type { 'High School Diploma' }
        grade { %w[pass merit distinction].sample }
        institution_country { Faker::Address.country_code }
        enic_reference { '4000123456' }
        enic_reason { 'obtained' }
        comparable_uk_qualification { 'Between GCSE and GCSE AS Level' }
      end

      trait :missing_and_currently_completing do
        qualification_type { 'missing' }
        grade { nil }
        predicted_grade { nil }
        award_year { nil }
        currently_completing_qualification { true }
        not_completed_explanation { 'I will be taking an equivalency test in a few weeks' }
      end

      trait :missing_and_not_currently_completing do
        qualification_type { 'missing' }
        grade { nil }
        predicted_grade { nil }
        award_year { nil }
        currently_completing_qualification { false }
        missing_explanation { 'I have 10 years experience teaching English Language' }
      end

      trait :science_gcse do
        subject { ['science single award', 'science double award', 'science triple award'].sample }

        grade {
          if subject == 'science single award'
            %w[A B C].sample
          elsif subject == 'science double award'
            %w[AA BB CC].sample
          end
        }

        constituent_grades {
          if subject == 'science triple award'
            { biology: { grade: 'A' }, physics: { grade: 'D' }, chemistry: { grade: 'B' } }
          end
        }
      end

      trait :science_triple_award do
        science_gcse

        subject { 'science triple award' }
      end

      trait :multiple_english_gcses do
        grade { nil }
        subject { 'english' }
        constituent_grades { { english_language: { grade: 'A', public_id: 120282 }, english_literature: { grade: 'D', public_id: 120283 } } }
      end
    end

    factory :degree_qualification do
      level { 'degree' }
      qualification_type { Hesa::DegreeType.all.sample.name }
      subject { Hesa::Subject.all.sample.name }
      institution_name { Hesa::Institution.all.sample.name }
      grade { Hesa::Grade.all.sample.description }
      start_year { Faker::Date.between(from: 5.years.ago, to: 3.years.ago).year }
      award_year { Faker::Date.between(from: 2.years.ago, to: 1.year.ago).year }
      international { false }
      institution_country { 'GB' }
      predicted_grade { true }

      after(:build) do |degree, _evaluator|
        degree.qualification_type_hesa_code = Hesa::DegreeType.find_by_name(degree.qualification_type)&.hesa_code
        degree.subject_hesa_code = Hesa::Subject.find_by_name(degree.subject)&.hesa_code
        degree.institution_hesa_code = Hesa::Institution.find_by_name(degree.institution_name)&.hesa_code
        degree.grade_hesa_code = Hesa::Grade.find_by_description(degree.grade)&.hesa_code
      end

      trait :incomplete do
        start_year { nil }
        predicted_grade { nil }
      end

      trait :adviser_sign_up_applicable do
        grade { Adviser::ApplicationFormValidations::APPLICABLE_DOMESTIC_DEGREE_GRADES.sample }
        qualification_level { Adviser::ApplicationFormValidations::APPLICABLE_DOMESTIC_DEGREE_LEVELS.sample }
      end

      trait :bachelor do
        qualification_level { 'bachelor' }
        qualification_type {
          ['Bachelor of Arts', 'Bachelor of Engineering', 'Bachelor of Science', 'Bachelor of Education'].sample
        }
      end
    end

    factory :non_uk_degree_qualification do
      international { true }
      level { 'degree' }
      institution_country { 'FR' }
      qualification_type { 'Diplôme' }
      subject { Hesa::Subject.all.sample.name }
      institution_name { Faker::University.name }
      grade { '94%' }
      predicted_grade { false }
      start_year { Faker::Date.between(from: 5.years.ago, to: 3.years.ago).year }
      award_year { Faker::Date.between(from: 2.years.ago, to: 1.year.ago).year }
      enic_reference { '4000228363' }
      enic_reason { 'obtained' }
      comparable_uk_degree { 'bachelor_ordinary_degree' }

      trait :adviser_sign_up_applicable do
        comparable_uk_degree { Adviser::ApplicationFormValidations::APPLICABLE_INTERNATIONAL_DEGREE_LEVELS.sample }
      end
    end

    factory :other_qualification do
      level { 'other' }
      qualification_type { 'Other' }
      other_uk_qualification_type { Faker::Educator.subject }
      subject { Faker::Educator.subject }
      institution_name { Faker::University.name }
      grade { %w[pass merit distinction].sample }
      predicted_grade { false }
      institution_country { 'GB' }
      award_year { Faker::Date.between(from: 7.years.ago, to: 6.years.ago).year }

      trait :non_uk do
        level { 'other' }
        qualification_type { 'non_uk' }
        non_uk_qualification_type { Faker::Educator.subject }
        subject { Faker::Educator.subject }
        institution_name { Faker::University.name }
        grade { %w[pass merit distinction].sample }
        institution_country { Faker::Address.country_code }
      end
    end

    factory :as_level_qualification do
      level { 'other' }
      qualification_type { 'AS level' }
      subject { Faker::Educator.subject }
      institution_name { Faker::University.name }
      grade { 'A' }
      predicted_grade { false }
      institution_country { 'GB' }
      award_year { Faker::Date.between(from: 7.years.ago, to: 6.years.ago).year }
    end
  end
end
