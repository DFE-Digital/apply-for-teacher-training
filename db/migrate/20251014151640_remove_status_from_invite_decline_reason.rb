class RemoveStatusFromInviteDeclineReason < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column(:pool_invite_decline_reasons, :status, :string, default: 'draft')
    end
  end
end
