require 'rails_helper'

RSpec.describe DataMigrations::BackfillCandidateAPIUpdatedAt do
  describe '#change' do
    it 'backfills candidate_api_updated_at with the created_at date if nil' do
      candidate = create(:candidate, candidate_api_updated_at: nil)

      described_class.new.change

      expect(candidate.reload.candidate_api_updated_at).to eq candidate.created_at
    end
  end
end
