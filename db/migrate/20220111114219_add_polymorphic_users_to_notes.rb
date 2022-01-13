class AddPolymorphicUsersToNotes < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_column :notes, :user_id, :bigint
    add_column :notes, :user_type, :string
    add_index :notes, %i[user_id user_type], algorithm: :concurrently
  end

  def down
    remove_column :notes, :user_id
    remove_column :notes, :user_type
    remove_index :notes, name: 'index_notes_on_user_id_and_user_type'
  end
end
