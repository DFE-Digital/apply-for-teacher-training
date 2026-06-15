require 'rails_helper'

RSpec.describe DeactivateStaleServiceAPITokensWorker do
  describe '#perform' do
    it 'deletes stale tokens for service users' do
      # delete these
      used_more_than_three_months_ago = create(
        :authentication_token,
        user: ServiceAPIUser.last,
        used_at: 3.months.ago - 1.day,
      )
      created_not_used_more_than_three_months_ago = create(
        :authentication_token,
        user: ServiceAPIUser.last,
        used_at: nil,
        created_at: 3.months.ago - 1.day,
      )

      # keep these
      used_within_three_months_ago = create(
        :authentication_token,
        user: ServiceAPIUser.last,
        used_at: 2.months.ago,
      )
      created_not_used_within_three_months_ago = create(
        :authentication_token,
        user: ServiceAPIUser.last,
        used_at: nil,
        created_at: 2.months.ago,
      )

      expect { described_class.new.perform }.to change { AuthenticationToken.count }.by(-2)

      expect(created_not_used_within_three_months_ago.reload.present?).to be true
      expect(used_within_three_months_ago.reload.present?).to be true

      expect { created_not_used_more_than_three_months_ago.reload }.to raise_error(ActiveRecord::RecordNotFound)
      expect { used_more_than_three_months_ago.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
