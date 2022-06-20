class RemoveTempSiteIdFromCourseOptions < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :course_options, :temp_site_id, :bigint }
  end
end
