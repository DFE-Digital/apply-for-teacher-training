require 'rails_helper'

RSpec.describe DegreeGradeEvaluator do
  let(:application_form) { create(:application_form) }
  let(:course_option) { create(:course_option, course: create(:course, degree_grade: 'two_one')) }

  let(:application_choice) do
    build_stubbed(
      :application_choice,
      status: :unsubmitted,
      course_option:,
      application_form:,
    )
  end

  subject(:evaluator) { described_class.new(application_choice) }

  context 'application has no degree and course has requirement' do
    it 'returns the required course degree text' do
      expect(evaluator.course_degree_requirement_text).to eq('2:1 degree or higher (or equivalent)')
      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has uk degree but degree grade marked as not_required' do
    let(:course_option) { create(:course_option, course: create(:course, degree_grade: 'not_required')) }

    it 'returns any degree grade and below required grade is false' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: 'GB',
        grade: 'Upper second-class honours (2:1)',
        qualification_type_hesa_code: 51,
        application_form:,
        predicted_grade: false,
      )

      expect(evaluator.course_degree_requirement_text).to eq('Any degree grade')
      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has other degree and course has requirement' do
    it 'returns required degree text and below required grade is false' do
      create(
        :degree_qualification,
        qualification_type: 'Other Qual',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        application_form:,
        predicted_grade: false,
      )

      expect(evaluator.course_degree_requirement_text).to eq('2:1 degree or higher (or equivalent)')
      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has non-UK degree' do
    it 'returns required degree text and below required grade is false' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        qualification_type_hesa_code: 51,
        institution_country: 'Armenia',
        grade: 'Lower second-class honours (2:2)',
        application_form:,
        predicted_grade: false,
      )

      expect(evaluator.course_degree_requirement_text).to eq('2:1 degree or higher (or equivalent)')
      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has degree with non-standard grade' do
    it 'returns required degree text and below required grade is false' do
      create(
        :degree_qualification,
        qualification_type: 'Master of Arts',
        institution_country: nil,
        qualification_type_hesa_code: 200,
        grade: 'Merit',
        application_form:,
        predicted_grade: false,
      )

      expect(evaluator.course_degree_requirement_text).to eq('2:1 degree or higher (or equivalent)')
      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has degree at required level' do
    it 'returns required degree text and below required grade is false' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: 'GB',
        grade: 'Upper second-class honours (2:1)',
        qualification_type_hesa_code: 51,
        application_form:,
        predicted_grade: false,
      )

      expect(evaluator.course_degree_requirement_text).to eq('2:1 degree or higher (or equivalent)')
      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has a degree with grade below required level' do
    it 'returns below required grade true' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        qualification_type_hesa_code: 51,
        application_form:,
        predicted_grade: false,
      )

      expect(evaluator.degree_grade_below_required_grade?).to be(true)
      expect(evaluator.highest_degree_grade).to eq('Lower second-class honours (2:2)')
    end
  end

  context 'application has a degree with grade below required level but it is predicted' do
    it 'returns below required grade true' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        qualification_type_hesa_code: 51,
        application_form:,
        predicted_grade: true,
      )

      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has a masters degree and a bachelors degree below requirement' do
    it 'returns below required grade false' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        qualification_type_hesa_code: 51,
        application_form:,
        predicted_grade: false,
      )

      create(
        :degree_qualification,
        qualification_type: 'Master of Arts',
        institution_country: nil,
        qualification_type_hesa_code: 200,
        grade: 'Merit',
        application_form:,
      )

      expect(evaluator.degree_grade_below_required_grade?).to be(false)
    end
  end

  context 'application has a mixture of valid and invalid degree grades' do
    it 'returns below required grade true only for the valid UK bachelor' do
      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: 'GB',
        grade: 'Lower second-class honours (2:2)',
        qualification_type_hesa_code: 51,
        application_form:,
        predicted_grade: false,
      )

      create(
        :degree_qualification,
        qualification_type: 'Bachelor of Arts',
        institution_country: nil,
        qualification_type_hesa_code: 200,
        grade: 'Merit',
        application_form:,
      )

      expect(evaluator.degree_grade_below_required_grade?).to be(true)
      expect(evaluator.highest_degree_grade).to eq('Lower second-class honours (2:2)')
    end
  end
end
