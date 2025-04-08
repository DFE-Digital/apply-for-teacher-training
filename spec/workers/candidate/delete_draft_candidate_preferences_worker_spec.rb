require 'rails_helper'

RSpec.describe Candidate::DeleteDraftCandidatePreferencesWorker do
  describe '#perform' do
    it 'deletes draft withdrawal reason records that are over 3 days old' do
      create(:candidate_preference, :published, updated_at: 3.days.ago)
      create(:candidate_preference, :published, updated_at: 4.days.ago)
      create(:candidate_preference, :draft, updated_at: 3.days.ago)
      create(:candidate_preference, :draft, updated_at: Time.zone.now)
      deletable_record = create(:candidate_preference, :draft, updated_at: 4.days.ago)

      expect { described_class.new.perform }.to change { CandidatePreference.count }.by(-1)

      expect { deletable_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
