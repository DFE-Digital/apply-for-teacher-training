class ValidateMakeCourseOptionsSiteIdNotNullable < ActiveRecord::Migration[7.0]
  def change
    validate_check_constraint :course_options, name: 'course_options_site_id_null'
    safety_assured { change_column_null :course_options, :site_id, false }
    remove_check_constraint :course_options, name: 'course_options_site_id_null'
  end
end
