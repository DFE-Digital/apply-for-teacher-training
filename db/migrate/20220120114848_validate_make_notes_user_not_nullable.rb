class ValidateMakeNotesUserNotNullable < ActiveRecord::Migration[6.1]
  def change
    validate_check_constraint :notes, name: "notes_user_id_null"
  end
end
