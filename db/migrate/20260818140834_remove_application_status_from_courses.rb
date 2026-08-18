class RemoveApplicationStatusFromCourses < ActiveRecord::Migration[8.1]
  def change
    safety_assured do
      remove_column :courses, :application_status, :integer, default: 0, null: false
    end
  end
end
