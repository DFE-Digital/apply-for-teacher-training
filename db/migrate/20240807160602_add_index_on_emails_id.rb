class AddIndexOnEmailsId < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :emails, :id, algorithm: :concurrently
  end
end
