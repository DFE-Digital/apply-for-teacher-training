class AddIndexOnApplicationFormUpdatedAt < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :application_forms, :updated_at, order: { updated_at: :desc }, algorithm: :concurrently
  end
end
