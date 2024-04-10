class AddIndexToVenderName < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :vendors, :name, unique: true, algorithm: :concurrently
  end
end
