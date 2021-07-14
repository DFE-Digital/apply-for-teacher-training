class AddIndexToEmailsNotifyReference < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :emails, :notify_reference, unique: true, algorithm: :concurrently
  end
end
