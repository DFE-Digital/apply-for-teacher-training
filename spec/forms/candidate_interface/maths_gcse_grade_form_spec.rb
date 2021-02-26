require 'rails_helper'

RSpec.describe CandidateInterface::MathsGcseGradeForm, type: :model do
  describe 'validations' do
    let(:subject) { form }
    let(:form) { described_class.new(grade: 'D', qualification_type: 'gcse') }

    it { is_expected.to validate_presence_of(:grade) }

    context 'when grade is "other"' do
      let(:form) { described_class.new(grade: 'other', other_grade: 'D', qualification_type: 'gcse') }

      it { is_expected.to validate_presence_of(:other_grade) }
    end

    context 'when qualification type is GCSE' do
      let(:form) { described_class.new(qualification_type: 'gcse') }

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
        gcse = double
        form.grade = 'XYZ'

        form.save(gcse)

        expect(Rails.logger).to have_received(:info).with(
          'Validation error: {:field=>"grade", :error_messages=>"Enter a real grade", :value=>"XYZ"}',
        )
      end
    end

    context 'when qualification type is GCE O LEVEL' do
      let(:form) { described_class.new(qualification_type: 'gce_o_level') }

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
    end

    context 'when qualification type is Scottish National 5' do
      let(:form) { described_class.new(qualification_type: 'scottish_national_5') }

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
    describe '#save_grade' do
      it 'return false if not valid' do
        gcse = double
        form = described_class.new
        expect(form.save(gcse)).to eq(false)
      end

      it 'sanitises the grade and updates the gcse grade if valid' do
        gcse = create(:gcse_qualification)
        form = described_class.new(grade: ' a ', qualification_type: 'gcse')

        form.save(gcse)

        expect(gcse.reload.grade).to eq('A')
      end

      it 'sets grade to other_grade if candidate selected "non-uk"' do
        gcse = create(:gcse_qualification)
        form = described_class.new(grade: 'other', other_grade: 'D', qualification_type: 'non_uk')

        form.save(gcse)

        expect(gcse.reload.grade).to eq('D')
      end
    end

    describe '.build_from_qualification' do
      context 'when it is a uk qualification' do
        it 'sets grade and qualification_type' do
          qualification = build_stubbed(:gcse_qualification, grade: 'A')
          gcse_details_form = described_class.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'A'
          expect(gcse_details_form.qualification_type).to eq 'gcse'
        end
      end

      context 'when the qualification_type is non_uk and grade is not_applicable' do
        it 'sets grade to not_applicable and other grade to nil' do
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'n/a')
          gcse_details_form = described_class.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'not_applicable'
          expect(gcse_details_form.other_grade).to eq nil
          expect(gcse_details_form.qualification_type).to eq 'non_uk'
        end
      end

      context 'when the qualification_type is non_uk grade is unknown' do
        it 'sets grade to not_applicable and other grade to nil' do
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'unknown')
          gcse_details_form = described_class.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'unknown'
          expect(gcse_details_form.other_grade).to eq nil
          expect(gcse_details_form.qualification_type).to eq 'non_uk'
        end
      end

      context 'when the qualification_type is non_uk and the grade is another value' do
        it 'sets grade to other and other grade to grades value' do
          qualification = build_stubbed(:gcse_qualification, qualification_type: 'non_uk', grade: 'D')
          gcse_details_form = described_class.build_from_qualification(qualification)

          expect(gcse_details_form.grade).to eq 'other'
          expect(gcse_details_form.other_grade).to eq 'D'
          expect(gcse_details_form.qualification_type).to eq 'non_uk'
        end
      end
    end
  end
end
