class MakeCourseOptionsSiteIdNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :course_options, :site_id, true
  end
end
