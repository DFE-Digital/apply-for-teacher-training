class AddIndexOnEmailCreatedAt < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :emails, :created_at, algorithm: :concurrently
  end
end
