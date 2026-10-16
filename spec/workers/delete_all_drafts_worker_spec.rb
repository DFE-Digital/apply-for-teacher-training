require 'rails_helper'

RSpec.describe DeleteAllDraftsWorker do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    it 'runs delete draft withdrawal reasons worker' do
      perform

      expect(
        Candidate::DeleteDraftWithdrawalReasonRecordsWorker,
      ).to have_been_enqueued
    end

    it 'runs delete draft pool invites worker' do
      perform

      expect(
        Provider::DeleteDraftPoolInvitesWorker,
      ).to have_been_enqueued
    end

    it 'runs delete draft candidate preferences worker' do
      perform

      expect(
        Candidate::DeleteDraftCandidatePreferencesWorker,
      ).to have_been_enqueued
    end
  end
end
