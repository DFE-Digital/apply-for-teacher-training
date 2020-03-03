class RenameSupportUsersDeletedAtToDiscardedAt < ActiveRecord::Migration[6.0]
  def change
    rename_column :support_users, :deleted_at, :discarded_at
  end
end
