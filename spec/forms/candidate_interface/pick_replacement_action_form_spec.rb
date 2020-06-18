require 'rails_helper'

RSpec.describe CandidateInterface::PickReplacementActionForm, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:replacement_action) }
  end
end
