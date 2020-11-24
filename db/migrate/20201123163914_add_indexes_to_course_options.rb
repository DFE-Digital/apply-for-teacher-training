class AddIndexesToCourseOptions < ActiveRecord::Migration[6.0]
  def change
    add_index :course_options, %i[vacancy_status site_still_valid]
  end
end
