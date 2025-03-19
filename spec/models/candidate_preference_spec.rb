require 'rails_helper'

RSpec.describe CandidatePreference do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to have_many(:location_preferences).class_name('CandidateLocationPreference') }
  end
end
