require 'rails_helper'

RSpec.describe CandidateInterface::GcseQualificationTypeForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:level) }
    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:qualification_type) }
  end

  describe '#save_base' do
    it 'return false if not valid' do
      application_form = double

      form = CandidateInterface::GcseQualificationTypeForm.new({})
      expect(form.save_base(application_form)).to eq(false)
    end

    it 'creates a new qualification if valid' do
      application_form = create(:application_form)

      gcse_qualification_type = CandidateInterface::GcseQualificationTypeForm
                                  .new(subject: 'maths', level: 'gcse', qualification_type: 'gsce')

      expect(gcse_qualification_type.save_base(application_form)).to eq(true)
    end
  end
end
