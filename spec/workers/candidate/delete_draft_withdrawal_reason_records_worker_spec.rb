require 'rails_helper'

RSpec.describe Candidate::DeleteDraftWithdrawalReasonRecordsWorker do
  describe '#perform' do
    it 'deletes draft withdrawal reason records that are over 3 days old' do
      create(:withdrawal_reason, :published, updated_at: 3.days.ago)
      create(:withdrawal_reason, :published, updated_at: 4.days.ago)
      create(:withdrawal_reason, :draft, updated_at: 3.days.ago)
      create(:withdrawal_reason, :draft)
      deletable_record = create(:withdrawal_reason, :draft, updated_at: 4.days.ago)

      expect { described_class.new.perform }.to change { WithdrawalReason.count }.by(-1)

      expect { deletable_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
