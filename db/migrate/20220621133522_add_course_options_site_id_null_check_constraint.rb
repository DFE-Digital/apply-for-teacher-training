class AddCourseOptionsSiteIdNullCheckConstraint < ActiveRecord::Migration[7.0]
  def change
    add_check_constraint :course_options, 'site_id IS NOT NULL', name: 'course_options_site_id_null', validate: false
  end
end
