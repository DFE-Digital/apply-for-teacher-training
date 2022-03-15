require 'rails_helper'

RSpec.describe CandidateInterface::ImmigrationRightToWorkForm, type: :model do
  describe '#validations' do
    it { is_expected.to validate_presence_of(:right_to_work_or_study) }
  end

  describe '.build_from_application' do
    let(:form_data) do
      {
        right_to_work_or_study: 'yes',
      }
    end

    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(form_data)
      form = described_class.build_from_application(application_form)
      expect(form).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      form = described_class.new

      expect(form.save(ApplicationForm.new)).to be(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      form_data = { right_to_work_or_study: 'yes' }
      application_form = create(:application_form)
      form = described_class.new(form_data)

      expect(form.save(application_form)).to be(true)
      expect(application_form.right_to_work_or_study).to eq('yes')
    end

    it 'resets redundant attributes if right to work is false' do
      application_data = {
        right_to_work_or_study: 'yes',
        immigration_status: 'other',
        right_to_work_or_study_details: 'I have permanent residence',
      }
      application_form = create(:application_form, application_data)
      form = described_class.new(right_to_work_or_study: 'no')

      expect(form.save(application_form)).to be(true)
      expect(application_form.reload.right_to_work_or_study).to eq('no')
      expect(application_form.immigration_status).to be_nil
      expect(application_form.immigration_status_details).to be_nil
    end

    it 'does not reset attributes if right to work is true' do
      application_data = {
        right_to_work_or_study: 'no',
        immigration_status: 'other',
        right_to_work_or_study_details: 'I have permanent residence',
      }
      application_form = create(:application_form, application_data)
      form = described_class.new(right_to_work_or_study: 'yes')

      expect(form.save(application_form)).to be(true)
      expect(application_form.reload.right_to_work_or_study).to eq('yes')
      expect(application_form.immigration_status).not_to be_nil
      expect(application_form.right_to_work_or_study_details).not_to be_nil
    end
  end
end
