require 'rails_helper'

RSpec.describe DeleteAllDraftsWorker do
  describe '#perform' do
    let(:delete_drafts) { described_class.new.perform }

    it 'queues up delete draft withdrawal reasons worker' do
      expect { delete_drafts }.to change(
        Candidate::DeleteDraftWithdrawalReasonRecordsWorker.jobs, :size
      ).by(1)
    end

    it 'queues up delete draft pool invites worker' do
      expect { delete_drafts }.to change(
        Provider::DeleteDraftPoolInvitesWorker.jobs, :size
      ).by(1)
    end

    it 'queues up delete draft candidate preferences worker' do
      expect { delete_drafts }.to change(
        Candidate::DeleteDraftCandidatePreferencesWorker.jobs, :size
      ).by(1)
    end
  end
end
