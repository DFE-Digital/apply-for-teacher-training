class AddCheckConstraintForNotesUserIdNotNull < ActiveRecord::Migration[6.1]
  def change
    add_check_constraint :notes, 'user_id IS NOT NULL', name: 'notes_user_id_null', validate: false
  end
end
