require 'rails_helper'

RSpec.describe CandidateInterface::ContactDetailsForm, type: :model do
  let(:data) do
    {
      phone_number: '07700 900 982',
    }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = build_stubbed(:application_form, data)
      contact_details = CandidateInterface::ContactDetailsForm.build_from_application(
        application_form,
      )

      expect(contact_details).to have_attributes(data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      contact_details = CandidateInterface::ContactDetailsForm.new

      expect(contact_details.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = build(:application_form, data)
      contact_details = CandidateInterface::ContactDetailsForm.new(data)

      expect(contact_details.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end
end
