class AddStatusAndRejectionReasonToPoolInvite < ActiveRecord::Migration[8.0]
  def change
    add_column(:pool_invites, :candidate_invite_status, :string, null: false, default: 'new')
    add_column(:pool_invites, :dismiss_reason, :string)
    add_column(:pool_invites, :dismiss_text, :text)
  end
end
