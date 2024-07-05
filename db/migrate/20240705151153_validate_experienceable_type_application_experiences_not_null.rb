class ValidateExperienceableTypeApplicationExperiencesNotNull < ActiveRecord::Migration[7.1]
  def change
    validate_check_constraint :application_experiences, name: "application_experiences_experienceable_type_null"
    change_column_null :application_experiences, :experienceable_type, false
    remove_check_constraint :application_experiences, name: "application_experiences_experienceable_type_null"
  end
end
