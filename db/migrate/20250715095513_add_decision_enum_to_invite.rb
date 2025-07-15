class AddDecisionEnumToInvite < ActiveRecord::Migration[8.0]
  def change
    add_column :pool_invites, :candidate_decision, :string, default: 'not_responded'
  end
end
