require 'rails_helper'

RSpec.describe CandidateLocationPreference do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate_preference) }
  end
end
