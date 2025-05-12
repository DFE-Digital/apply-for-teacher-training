require 'rails_helper'

RSpec.describe CandidateLocationPreference do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate_preference) }
    it { is_expected.to belong_to(:provider).optional }
  end
end
