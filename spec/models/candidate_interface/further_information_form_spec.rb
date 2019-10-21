require 'rails_helper'

RSpec.describe CandidateInterface::FurtherInformationForm, type: :model do
  describe '#save' do
    it 'returns false if not valid' do
      further_information = CandidateInterface::FurtherInformationForm.new

      expect(further_information.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      data = {
        further_information: true,
        further_information_details: 'Much wow.',
      }
      application_form = FactoryBot.create(:application_form)
      further_information = CandidateInterface::FurtherInformationForm.new(data)

      expect(further_information.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:further_information) }

    it 'validates further information details if chosen to add further information' do
      further_information = CandidateInterface::FurtherInformationForm.new(further_information: true)
      error_message = t('activemodel.errors.models.candidate_interface/further_information_form.attributes.further_information_details.blank')

      further_information.validate

      expect(further_information.errors.full_messages_for(:further_information_details)).to eq(
        ["Further information details #{error_message}"],
      )
    end

    okay_text = Faker::Lorem.sentence(word_count: 300)
    long_text = Faker::Lorem.sentence(word_count: 301)

    it { is_expected.to allow_value(okay_text).for(:further_information_details) }
    it { is_expected.not_to allow_value(long_text).for(:further_information_details) }
  end
end
