class DropCoursesStartDate < ActiveRecord::Migration[6.0]
  def change
    remove_column :courses, :start_date, :date
  end
end
