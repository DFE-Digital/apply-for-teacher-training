require 'rails_helper'

RSpec.describe DeleteAllDraftsWorker do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    before do
      allow(Candidate::DeleteDraftWithdrawalReasonRecordsWorker)
        .to receive(:perform_later)

      allow(Provider::DeleteDraftPoolInvitesWorker)
        .to receive(:perform_later)

      allow(Candidate::DeleteDraftCandidatePreferencesWorker)
        .to receive(:perform_later)
    end

    it 'runs delete draft withdrawal reasons worker' do
      perform

      expect(
        Candidate::DeleteDraftWithdrawalReasonRecordsWorker,
      ).to have_received(:perform_later)
    end

    it 'runs delete draft pool invites worker' do
      perform

      expect(
        Provider::DeleteDraftPoolInvitesWorker,
      ).to have_received(:perform_later)
    end

    it 'runs delete draft candidate preferences worker' do
      perform

      expect(
        Candidate::DeleteDraftCandidatePreferencesWorker,
      ).to have_received(:perform_later)
    end
  end
end
