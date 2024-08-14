class ValidateApplicationExperienceExperienceableColumns < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def up
    validate_check_constraint :application_experiences, name: 'application_experiences_experienceable_id_null'
    change_column_null :application_experiences, :experienceable_id, false
    remove_check_constraint :application_experiences, name: 'application_experiences_experienceable_id_null'

    validate_check_constraint :application_experiences, name: 'application_experiences_experienceable_type_null'
    change_column_null :application_experiences, :experienceable_type, false
    remove_check_constraint :application_experiences, name: 'application_experiences_experienceable_type_null'
  end

  def down
    change_column_null :application_experiences, :experienceable_id, true
    change_column_null :application_experiences, :experienceable_type, true
  end
end
