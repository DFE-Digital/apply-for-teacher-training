require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationDetailsForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:grade) }
    it { is_expected.to validate_presence_of(:award_year) }
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
