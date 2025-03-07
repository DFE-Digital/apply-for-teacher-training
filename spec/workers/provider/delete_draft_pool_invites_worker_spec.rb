require 'rails_helper'

RSpec.describe Provider::DeleteDraftPoolInvitesWorker do
  describe '#perform' do
    it 'deletes draft pool invites records that are over 3 days old' do
      create(:pool_invite, :published, updated_at: 3.days.ago)
      create(:pool_invite, :published, updated_at: 4.days.ago)
      create(:pool_invite, :draft, updated_at: 3.days.ago)
      create(:pool_invite, :draft)
      deletable_record = create(:pool_invite, :draft, updated_at: 4.days.ago)

      expect { described_class.new.perform }.to change { Pool::Invite.count }.by(-1)

      expect { deletable_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
