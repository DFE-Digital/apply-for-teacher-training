require 'rails_helper'

RSpec.describe RemoveInactiveSupportUsersWorker do
  describe '#perform' do
    it 'discards inactive support users' do
      should_discard = create(:support_user, last_signed_in_at: 10.months.ago)
      should_not_discard = create(:support_user, last_signed_in_at: 8.months.ago)

      expect { described_class.new.perform }.to change { SupportUser.kept.count }.by(-1)
      expect(should_discard.reload.discarded_at.present?).to be(true)
      expect(should_not_discard.reload.discarded_at).to be_nil
    end
  end
end
