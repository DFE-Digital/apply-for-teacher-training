class RemoveSyncCoursesFromProvider < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :providers, :sync_courses, :boolean }
  end
end
