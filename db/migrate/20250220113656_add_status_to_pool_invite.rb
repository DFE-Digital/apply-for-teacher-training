class AddStatusToPoolInvite < ActiveRecord::Migration[8.0]
  def change
    add_column :pool_invites, :status, :string, null: false, default: 'draft'
  end
end
