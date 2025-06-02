class AddStatusAndRejectionReasonToPoolInvite < ActiveRecord::Migration[8.0]
  def change
    add_column(:pool_invites, :candidate_invite_status, :string, null: false, default: 'new')
    add_column(:pool_invites, :rejection_reason, :text)
  end
end
