require 'rails_helper'

RSpec.describe CandidateInterface::VolunteeringExperienceForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:experience) }
  end
end
