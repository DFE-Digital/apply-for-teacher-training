class MakeNotesUserNotNullable < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :notes, 'user_id IS NOT NULL', name: 'notes_user_id_null', validate: false
    change_column_null :notes, :user_id, false
    remove_check_constraint :notes, name: 'notes_user_id_null'
  end
end
