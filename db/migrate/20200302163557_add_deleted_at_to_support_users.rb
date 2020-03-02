class AddDeletedAtToSupportUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :support_users, :deleted_at, :datetime
    add_index :support_users, :deleted_at
  end
end
