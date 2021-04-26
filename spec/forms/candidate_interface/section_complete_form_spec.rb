require 'rails_helper'

RSpec.describe CandidateInterface::SectionCompleteForm, type: :model do
  describe 'validations' do
    it "validates presence of 'completed'" do
      degree_form = described_class.new(completed: nil)
      error_message_blank = t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.blank')
      error_message_inclusion = t('activemodel.errors.models.candidate_interface/section_complete_form.attributes.completed.inclusion')

      degree_form.validate

      expect(degree_form.errors.full_messages_for(:completed)).to eq(
        [
          "Completed #{error_message_blank}",
          "Completed #{error_message_inclusion}",
        ],
      )
    end
  end

  describe '#new' do
    it "sets the 'completed' attribute" do
      section_complete_form = described_class.new(completed: true)

      expect(section_complete_form.completed).to eq(true)
    end
  end

  describe '#save' do
    let(:application_form) { create(:application_form, :minimum_info, personal_details_completed: nil) }

    it 'returns false if not valid' do
      section_complete_form = described_class.new(completed: nil)

      expect(section_complete_form.save(application_form, :personal_details_completed)).to eq(false)
    end

    it "updates 'section completed' if valid" do
      section_complete_form = described_class.new(completed: true)

      expect(section_complete_form.save(application_form, :personal_details_completed)).to eq(true)
      expect(application_form.personal_details_completed).to eq(true)
    end
  end
end
