class AddCoursesLevel < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :level, :string
  end
end
