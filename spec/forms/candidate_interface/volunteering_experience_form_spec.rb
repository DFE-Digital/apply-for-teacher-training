require 'rails_helper'

RSpec.describe CandidateInterface::VolunteeringExperienceForm, type: :model do
  describe '#save' do
    it 'returns false if not valid' do
      volunteering_experience = described_class.new

      expect(volunteering_experience.save(ApplicationForm.new)).to be(false)
    end

    it 'updates volunteering experience if valid' do
      application_form = create(:application_form, volunteering_experience: true)
      volunteering_experience = described_class.new(experience: 'true')

      expect(volunteering_experience.save(application_form)).to be(true)
      expect(application_form.volunteering_experience).to be(true)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:experience) }
  end
end
