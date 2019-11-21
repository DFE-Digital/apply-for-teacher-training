require 'rails_helper'

RSpec.describe CandidateInterface::CourseChosenForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:choice) }
  end
end
