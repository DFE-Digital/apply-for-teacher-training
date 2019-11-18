require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }
    it { is_expected.to validate_length_of(:grade).is_at_most(6) }

    context 'when qualification type is GCSE' do
      let(:form) { CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification) }
      let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'gcse', level: 'gcse') }

      it 'returns no errors if grade is valid' do
        valid_grades = ['A*A*A*', 'ABC', 'AA', '863', 'a*a*a*', 'A B C', 'A-B-C']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[012 XYZ]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate
          expect(form.errors[:grade]).to include('Enter a real graduation grade')
        end
      end

      it 'logs validation errors if grade is invalid' do
        allow(Rails.logger).to receive(:info)
        form.grade = 'XYZ'

        form.save_base

        expect(Rails.logger).to have_received(:info).with(
          'Validation error: {:field=>"grade", :error_messages=>"Enter a real graduation grade", :value=>"XYZ"}',
        )
      end
    end

    context 'when qualification type is GCE O LEVEL' do
      let(:form) { CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification) }
      let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'gce_o_level', level: 'gcse') }

      it 'returns no errors if grade is valid' do
        valid_grades = ['ABC', 'AB', 'AA', 'abc', 'A B C', 'A-B-C']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[123 A* XYZ]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to include('Enter a real graduation grade')
        end
      end
    end

    context 'when qualification type is Scottish National 5' do
      let(:form) { CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification) }
      let(:qualification) { FactoryBot.build_stubbed(:application_qualification, qualification_type: 'scottish_national_5', level: 'gcse') }

      it 'returns no errors if grade is valid' do
        valid_grades = ['AAA', 'AAB', '765', 'CBD', 'aaa', 'C B D', 'C-B-D']

        valid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[89 AE A*]

        invalid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to include('Enter a real graduation grade')
        end
      end
    end
  end

  describe '#save_base' do
    it 'return false if not valid' do
      qualification = ApplicationQualification.new
      form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

      expect(form.save_base).to eq(false)
    end

    it 'updates qualification details if valid' do
      application_form = create(:application_form)
      qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
      details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

      details_form.grade = 'AB'
      details_form.award_year = '1990'

      details_form.save_base
      qualification.reload

      expect(qualification.grade).to eq('AB')
      expect(qualification.award_year).to eq('1990')
    end
  end
end
