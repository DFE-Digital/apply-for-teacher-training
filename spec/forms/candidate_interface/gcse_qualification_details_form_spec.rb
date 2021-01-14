require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:grade).on(:grade) }
    it { is_expected.to validate_presence_of(:award_year).on(:award_year) }

    context 'when grade is "other"' do
      let(:form) { subject }

      before { allow(form).to receive(:grade_is_other?).and_return(true) }

      it { is_expected.to validate_presence_of(:other_grade) }
    end

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

    context 'when qualification type is GCSE and subject is maths' do
      let(:form) { CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification) }
      let(:qualification) do
        FactoryBot.build_stubbed(:application_qualification,
                                 qualification_type: 'gcse',
                                 level: 'gcse',
                                 subject: 'maths')
      end

      it 'returns no errors if grade is valid' do
        mistyped_grades = [' A ', 'a']
        valid_grades = SINGLE_GCSE_GRADES + mistyped_grades

        valid_grades.each do |grade|
          form.grade = grade
          form.validate

          expect(form.errors[:grade]).to be_empty
        end
      end

      it 'return validation error if grade is invalid' do
        invalid_grades = %w[AA AAA X]

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
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter a real grade')
        end
      end

      it 'returns validation error if award year is after 1988' do
        form.award_year = '2012'
        form.validate(:award_year)

        expect(form.errors[:award_year]).to include('Enter a year before 1989 - GSCEs replaced O levels in 1988')
      end

      it 'returns no error if award year is valid' do
        valid_years = (1951..1988)

        valid_years.each do |year|
          form.award_year = year
          form.validate(:award_year)

          expect(form.errors[:award_year]).to be_empty
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
          form.validate(:grade)

          expect(form.errors[:grade]).to include('Enter a real grade')
        end
      end
    end
  end

  context 'when saving qualification details' do
    qualification = ApplicationQualification.new
    form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

    describe '#save_grade' do
      it 'return false if not valid' do
        expect(form.save_grade).to eq(false)
      end

      it 'updates qualification details if valid' do
        application_form = create(:application_form)
        qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
        details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

        details_form.grade = 'AB'

        details_form.save_grade
        qualification.reload

        expect(qualification.grade).to eq('AB')
      end

      it 'sets grade to other_grade if candidate selected "other"' do
        application_form = create(:application_form)
        qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
        details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

        details_form.grade = 'other'
        details_form.other_grade = 'D'

        details_form.save_grade
        qualification.reload

        expect(qualification.grade).to eq('D')
      end

      it 'saves a sanitized grade' do
        application_form = create(:application_form)
        qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
        details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

        details_form.grade = ' a '

        details_form.save_grade
        qualification.reload

        expect(qualification.grade).to eq('A')
      end
    end

    describe '#save_year' do
      it 'return false if not valid' do
        expect(form.save_year).to eq(false)
      end

      it 'returns validation error if award_year is in the future' do
        Timecop.freeze(Time.zone.local(2008, 1, 1)) do
          details_form = CandidateInterface::GcseQualificationDetailsForm.new(award_year: '2009')

          details_form.save_year

          expect(details_form.errors[:award_year]).to include('Enter a year before 2009')
        end
      end

      it 'updates qualification details if valid' do
        application_form = create(:application_form)
        qualification = ApplicationQualification.create(level: 'gcse', application_form: application_form)
        details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

        details_form.award_year = '1990'

        details_form.save_year
        qualification.reload

        expect(qualification.award_year).to eq('1990')
      end
    end

    describe '.build_from_qualification' do
      context 'when the qualification_type is non_uk and grade is not_applicable' do
        it 'sets grade to not_applicable and other grade to nil' do
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'n/a')
          gcse_details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'not_applicable'
          expect(gcse_details_form.other_grade).to eq nil
        end
      end

      context 'when the grade is unknown' do
        it 'sets grade to not_applicable and other grade to nil' do
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'unknown')
          gcse_details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'unknown'
          expect(gcse_details_form.other_grade).to eq nil
        end
      end

      context 'when grade is another value' do
        it 'sets grade to other and other grade to grades value' do
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'D')
          gcse_details_form = CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'other'
          expect(gcse_details_form.other_grade).to eq 'D'
        end
      end
    end
  end
end
