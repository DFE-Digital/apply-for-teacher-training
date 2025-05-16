class AddSentToCandidateAtToPoolInvites < ActiveRecord::Migration[8.0]
  def change
    add_column :pool_invites, :sent_to_candidate_at, :datetime, null: true
  end
end
