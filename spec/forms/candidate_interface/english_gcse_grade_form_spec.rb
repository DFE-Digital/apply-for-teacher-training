require 'rails_helper'

RSpec.describe CandidateInterface::EnglishGcseGradeForm, type: :model do
  describe 'validations' do
    context 'when grade is "other"' do
      let(:form) { subject }

      before { allow(form).to receive(:grade_is_other?).and_return(true) }

      it { is_expected.to validate_presence_of(:other_grade) }
    end

    context 'when qualification type is GCSE' do
      context 'multiple GCSEs enabled' do
        before do
          FeatureFlag.activate(:multiple_english_gcses)
        end

        let(:qualification) do
          FactoryBot.build_stubbed(
            :application_qualification,
            subject: 'english',
            qualification_type: 'gcse',
            level: 'gcse',
          )
        end
        let(:form) { CandidateInterface::EnglishGcseGradeForm.build_from_qualification(qualification) }

        it 'returns validation error if no GCSE is selected' do
          form.english_gcses = []
          form.validate(:structured_grades)

          expect(form.errors[:english_gcses]).to include('Select at least one GCSE')
        end

        it 'returns validation error if GCSE is selected but no grade is entered' do
          form.english_single_award = true
          form.grade_english_single = ''
          form.validate(:structured_grades)

          expect(form.errors[:grade_english_single]).to include('Enter your grade')
        end

        it 'returns validation error if GCSE is selected and an invalid grade is entered' do
          form.english_single_award = true
          form.grade_english_single = 'AWESOME'
          form.validate(:structured_grades)

          expect(form.errors[:grade_english_single]).to include('Enter a real grade')
        end

        it 'returns no errors if GCSE is selected and a valid grade is entered' do
          form.english_single_award = true
          form.grade_english_single = 'A*'
          form.validate(:structured_grades)

          expect(form.errors[:grade_english_single]).to be_empty
        end

        it 'returns validation error if other English GCSE is selected but no details are entered' do
          form.other_english_gcse = true
          form.other_english_gcse_name = ''
          form.grade_other_english_gcse = ''
          form.validate(:structured_grades)

          expect(form.errors[:other_english_gcse_name]).to include('Enter an English GCSE')
          expect(form.errors[:grade_other_english_gcse]).to include('Enter your grade')
        end
      end

      context 'multiple GCSEs disabled' do
        before do
          FeatureFlag.deactivate(:multiple_english_gcses)
        end

        let(:qualification) do
          FactoryBot.build_stubbed(
            :application_qualification,
            subject: 'english',
            qualification_type: 'gcse',
            level: 'gcse',
          )
        end
        let(:form) { CandidateInterface::EnglishGcseGradeForm.build_from_qualification(qualification) }

        it 'returns validation error if grade is blank' do
          form.grade = ''
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter your grade')
        end

        it 'returns no errors if grade is valid' do
          mistyped_grades = %w[a b c]
          valid_grades = SINGLE_GCSE_GRADES + mistyped_grades

          valid_grades.each do |grade|
            form.grade = grade
            form.validate

            expect(form.errors[:grade]).to be_empty
          end
        end

        it 'return validation error if grade is invalid' do
          invalid_grades = %w[012 XYZ T 54%]

          invalid_grades.each do |grade|
            form.grade = grade
            form.validate(:grade)

            expect(form.errors[:grade]).to include('Enter a real grade')
          end
        end

        it 'logs validation errors if grade is invalid' do
          allow(Rails.logger).to receive(:info)
          form.grade = 'XYZ'
          form.save

          expect(Rails.logger).to have_received(:info).with(
            'Validation error: {:field=>"grade", :error_messages=>"Enter a real grade", :value=>"XYZ"}',
          )
        end
      end
    end

    context 'when qualification type is GCE O LEVEL' do
      let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'gce_o_level', level: 'gcse', subject: 'english') }
      let(:form) { CandidateInterface::EnglishGcseGradeForm.build_from_qualification(qualification) }

      FeatureFlag.deactivate('multiple_english_gcses')

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
      FeatureFlag.deactivate('multiple_english_gcses')

      let(:qualification) do
        FactoryBot.build_stubbed(:application_qualification,
                                 qualification_type: 'scottish_national_5',
                                 level: 'gcse',
                                 subject: 'english')
      end
      let(:form) { CandidateInterface::EnglishGcseGradeForm.build_from_qualification(qualification) }

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
