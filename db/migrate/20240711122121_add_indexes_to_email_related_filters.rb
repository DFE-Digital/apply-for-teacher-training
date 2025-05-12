class AddIndexesToEmailRelatedFilters < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :candidates, :submission_blocked, algorithm: :concurrently
    add_index :candidates, :account_locked, algorithm: :concurrently
    add_index :candidates, :unsubscribed_from_emails, algorithm: :concurrently
  end
end
