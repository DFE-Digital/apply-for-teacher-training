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

  describe '#fill_form_values' do
    context 'when the database degree has a grade_hesa_code, for a HESA grade with visual_grouping "main"' do
      let(:degree) do
        build_stubbed(
          :degree_qualification,
          grade_hesa_code: 2,
        )
      end

      it 'sets the grade form attribute to the HESA grade description' do
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'Upper second-class honours (2:1)'
        expect(degree_form.other_grade).to be_blank
      end
    end

    context 'when the database degree has a grade_hesa_code, for a HESA grade with visual_grouping "other"' do
      let(:degree) do
        build_stubbed(
          :degree_qualification,
          grade_hesa_code: 4,
        )
      end

      it 'sets the other grade attributes' do
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.other_grade).to eq 'Undivided second class honours'
      end
    end

    context 'when the database degree is not a HESA value' do
      it 'sets the other grade attributes' do
        degree = build_stubbed(:degree_qualification, grade: 'gold medal')
        degree_form = described_class.new(degree: degree)

        degree_form.fill_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.other_grade).to eq 'gold medal'
      end
    end
  end
end
