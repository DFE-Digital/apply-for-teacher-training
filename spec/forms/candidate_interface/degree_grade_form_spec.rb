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

  describe '#other_grade' do
    subject(:form) do
      described_class.new(
        other_grade: 'Aegrotat',
        other_grade_raw: other_grade_raw,
      )
    end

    context 'when other grade raw is present' do
      let(:other_grade_raw) { 'General degree' }

      it 'returns raw value' do
        expect(form.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is empty' do
      let(:other_grade_raw) { '' }

      it 'returns raw value' do
        expect(form.other_grade).to eq(other_grade_raw)
      end
    end

    context 'when other grade raw is nil' do
      let(:other_grade_raw) { nil }

      it 'returns original value' do
        expect(form.other_grade).to eq('Aegrotat')
      end
    end
  end

  describe '#save' do
    let(:degree) do
      build(
        :degree_qualification,
        grade_hesa_code: 2,
      )
    end

    context 'when search by name' do
      it 'sets the grade uuid using the HESA grade description' do
        degree_form = described_class.new(degree: degree, grade: 'Upper second-class honours (2:1)')

        degree_form.save
        expect(degree_form.degree.degree_grade_uuid).to eq('e2fe18d4-8655-47cf-ab1a-8c3e0b0f078f')
      end
    end

    context 'when search by synonym' do
      it 'sets the grade uuid using the HESA grade description' do
        degree_form = described_class.new(degree: degree, grade: 'First class honours')

        degree_form.save
        expect(degree_form.degree.degree_grade_uuid).to eq('8741765a-13d8-4550-a413-c5a860a59d25')
      end
    end
  end

  describe '#assign_form_values' do
    context 'when the database degree has a grade_hesa_code, for a HESA grade with visual_grouping "main"' do
      let(:degree) do
        build_stubbed(
          :degree_qualification,
          grade_hesa_code: 2,
        )
      end

      it 'sets the grade form attribute to the HESA grade description' do
        degree_form = described_class.new(degree: degree)

        degree_form.assign_form_values

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

        degree_form.assign_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.other_grade).to eq 'Undivided second-class honours'
      end
    end

    context 'when the database degree is not a HESA value' do
      it 'sets the other grade attributes' do
        degree = build_stubbed(:degree_qualification, grade: 'gold medal')
        degree_form = described_class.new(degree: degree)

        degree_form.assign_form_values

        expect(degree_form.grade).to eq 'other'
        expect(degree_form.other_grade).to eq 'gold medal'
      end
    end

    context 'when the database degree has no grade info' do
      it 'sets no form values' do
        degree = build_stubbed(:degree_qualification, grade: nil)
        degree_form = described_class.new(degree: degree)

        degree_form.assign_form_values

        expect(degree_form.grade).to be_nil
        expect(degree_form.other_grade).to be_nil
      end
    end
  end
end
