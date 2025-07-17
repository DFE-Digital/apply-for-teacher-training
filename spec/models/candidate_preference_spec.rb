require 'rails_helper'

RSpec.describe CandidatePreference do
  describe 'associations' do
    it { is_expected.to belong_to(:candidate) }
    it { is_expected.to belong_to(:application_form).optional }
    it { is_expected.to have_many(:location_preferences).class_name('CandidateLocationPreference') }
  end

  describe '#create_draft_dup' do
    it 'creates a draft duplication of the preference and associated location_preferences' do
      candidate_preference = create(:candidate_preference, status: 'published')
      _location_preferences = create(:candidate_location_preference, candidate_preference:)

      expect { candidate_preference.create_draft_dup }.to change(described_class.draft, :count).by(1)
        .and change(CandidateLocationPreference, :count).by(1)
    end
  end
end
