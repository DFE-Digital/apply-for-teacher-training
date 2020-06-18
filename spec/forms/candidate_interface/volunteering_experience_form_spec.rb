require 'rails_helper'

RSpec.describe CandidateInterface::VolunteeringExperienceForm, type: :model do
  describe '#save' do
    it 'returns false if not valid' do
      volunteering_experience = CandidateInterface::VolunteeringExperienceForm.new

      expect(volunteering_experience.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates volunteering experience if valid' do
      application_form = create(:application_form, volunteering_experience: true)
      volunteering_experience = CandidateInterface::VolunteeringExperienceForm.new(experience: 'true')

      expect(volunteering_experience.save(application_form)).to eq(true)
      expect(application_form.volunteering_experience).to eq(true)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:experience) }
  end
end
