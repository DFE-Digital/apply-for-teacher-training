require 'rails_helper'

RSpec.describe CandidateInterface::EnglishGcseGradeForm, type: :model do
  describe 'validations' do
    context 'when grade is "other"' do
      let(:form) { subject }

      before { allow(form).to receive(:grade_is_other?).and_return(true) }

      it { is_expected.to validate_presence_of(:other_grade) }
    end

    context 'when qualification type is GCSE' do
      let(:qualification) do
        build_stubbed(
          :application_qualification,
          subject: 'english',
          qualification_type: 'gcse',
          level: 'gcse',
        )
      end
      let(:form) { described_class.build_from_qualification(qualification) }

      it 'returns validation error if no GCSE is selected' do
        form.english_gcses = []
        form.validate(:constituent_grades)

        expect(form.errors[:english_gcses]).to include('Select at least one GCSE')
      end

      it 'returns validation error if GCSE is selected but no grade is entered' do
        form.english_single_award = true
        form.grade_english_single = ''
        form.validate(:constituent_grades)

        expect(form.errors[:grade_english_single]).to include('Enter your English (Single award) grade')
      end

      it 'returns validation error if GCSE is selected and an invalid grade is entered' do
        form.english_single_award = true
        form.grade_english_single = 'AWESOME'
        form.validate(:constituent_grades)

        expect(form.errors[:grade_english_single]).to include('Enter a real English (Single award) grade')
      end

      it 'returns no errors if GCSE is selected and a valid grade is entered' do
        form.english_single_award = true
        form.grade_english_single = 'A*'
        form.validate(:constituent_grades)

        expect(form.errors[:grade_english_single]).to be_empty
      end

      it 'returns validation error if other English GCSE is selected but no details are entered' do
        form.other_english_gcse = true
        form.other_english_gcse_name = ''
        form.grade_other_english_gcse = ''
        form.validate(:constituent_grades)

        expect(form.errors[:other_english_gcse_name]).to include('Enter an English GCSE')
        expect(form.errors[:grade_other_english_gcse]).to include('Enter your other English subject grade')
      end
    end

    context 'when qualification type is GCE O LEVEL' do
      let(:qualification) { build_stubbed(:application_qualification, qualification_type: 'gce_o_level', level: 'gcse', subject: 'english') }
      let(:form) { described_class.build_from_qualification(qualification) }

      it 'returns no errors if grade is valid' do
        valid_grades = ['ABC', 'AB', 'AA', 'abc', 'A B C', 'A-B-C']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate(:grade)

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[123 A* XYZ]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter a real grade')
        end
      end
    end

    context 'when qualification type is Scottish National 5' do
      let(:qualification) do
        build_stubbed(:application_qualification,
                      qualification_type: 'scottish_national_5',
                      level: 'gcse',
                      subject: 'english')
      end
      let(:form) { described_class.build_from_qualification(qualification) }

      it 'returns no errors if grade is valid' do
        valid_grades = ['AAA', 'AAB', '765', 'CBD', 'aaa', 'C B D', 'C-B-D']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate(:grade)

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[89 AE A*]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter a real grade')
        end
      end
    end
  end
end
