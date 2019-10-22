class AddCoursesStartDate < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :start_date, :date
  end
end
