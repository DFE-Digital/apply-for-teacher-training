require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }

    describe 'grade format' do
      let(:form) do
        qualification = ApplicationQualification.create(qualification_type: 'gcse', level: 'gcse',
                                                        application_form: create(:application_form))
        CandidateInterface::GcseQualificationDetailsForm.build_from_qualification(qualification)
      end

      it 'return validation error if grade is invalid' do
        form.grade = 'aaz'

        form.save_base
        expect(form.errors[:grade]).to include('Enter a real graduation grade')
      end

      it 'returns no errors if grade is valid' do
        %w[aaa a*a*a* AB 123].each do |grade|
          form.grade = grade
          form.save_base

          expect(form.errors[:grade]).to be_empty
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
