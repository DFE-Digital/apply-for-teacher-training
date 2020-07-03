require 'rails_helper'

RSpec.describe CandidateInterface::DegreeGradeForm, type: :model do
  it "validates presence of `other_grade` if chosen grade is 'other'" do
    degree_form = described_class.new(grade: 'other')
    error_message = t('activemodel.errors.models.candidate_interface/degree_grade_form.attributes.other_grade.blank')

    degree_form.validate

    expect(degree_form.errors.full_messages_for(:other_grade)).to eq(
      ["Other grade #{error_message}"],
    )
  end

  it "validates presence of `predicted_grade` if chosen grade is 'predicted'" do
    degree_form = described_class.new(grade: 'predicted')
    error_message = t('activemodel.errors.models.candidate_interface/degree_grade_form.attributes.predicted_grade.blank')

    degree_form.validate

    expect(degree_form.errors.full_messages_for(:predicted_grade)).to eq(
      ["Predicted grade #{error_message}"],
    )
  end

  describe '#fill_form_values (HESA feature flag off)' do
    context 'when the database degree is marked as predicted' do
      it 'sets the predicted grade attributes' do
        degree = build_stubbed(:degree_qualification, grade: 'first', predicted_grade: true)
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'predicted'
        expect(degree_form.predicted_grade).to eq 'first'
      end
    end

    context 'when the database degree grade is one of the standard values' do
      it 'sets the grade attribute to that value' do
        degree = build_stubbed(:degree_qualification, grade: 'upper_second', predicted_grade: false)
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'upper_second'
        expect(degree_form.predicted_grade).to be_blank
        expect(degree_form.other_grade).to be_blank
      end
    end

    context 'when the database degree is neither predicted nor a standard value' do
      it 'sets the other grade attributes' do
        degree = build_stubbed(:degree_qualification, grade: 'gold medal', predicted_grade: false)
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.other_grade).to eq 'gold medal'
        expect(degree_form.predicted_grade).to be_blank
      end
    end
  end

  describe '#fill_form_values (HESA feature flag on)' do
    before { FeatureFlag.activate :hesa_degree_data }

    context 'when the database degree is marked as predicted' do
      let(:degree) { build_stubbed(:degree_qualification, grade: 'first', predicted_grade: true) }

      it 'sets the predicted grade form attributes' do
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'predicted'
        expect(degree_form.predicted_grade).to eq 'first'
        expect(degree_form.other_grade).to be_blank
      end
    end

    context 'when the database degree has a grade_hesa_code, for a HESA grade with visual_grouping "main"' do
      let(:degree) do
        build_stubbed(
          :degree_qualification,
          grade_hesa_code: 2,
          predicted_grade: false,
        )
      end

      it 'sets the grade form attribute to the HESA grade description' do
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'Upper second-class honours (2:1)'
        expect(degree_form.predicted_grade).to be_blank
        expect(degree_form.other_grade).to be_blank
      end
    end

    context 'when the database degree has a grade_hesa_code, for a HESA grade with visual_grouping "other"' do
      let(:degree) do
        build_stubbed(
          :degree_qualification,
          grade_hesa_code: 4,
          predicted_grade: false,
        )
      end

      it 'sets the other grade attributes' do
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.predicted_grade).to be_blank
        expect(degree_form.other_grade).to eq 'Undivided second class honours'
      end
    end

    context 'when the database degree is neither predicted nor a HESA value' do
      it 'sets the other grade attributes' do
        degree = build_stubbed(:degree_qualification, grade: 'gold medal', predicted_grade: false)
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.other_grade).to eq 'gold medal'
        expect(degree_form.predicted_grade).to be_blank
      end
    end
  end
end
