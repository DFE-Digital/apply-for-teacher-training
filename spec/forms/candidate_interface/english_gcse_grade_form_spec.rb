require 'rails_helper'

RSpec.describe CandidateInterface::EnglishGcseGradeForm, type: :model do
  describe 'validations' do
    context 'when grade is "other"' do
      let(:form) { subject }

      before { allow(form).to receive(:grade_is_other?).and_return(true) }

      it { is_expected.to validate_presence_of(:other_grade) }
    end

    context 'when qualification type is GCSE' do
      context 'multiple GCSEs disabled' do
        FeatureFlag.deactivate('multiple_english_gcses')
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
          form.save_grade

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
