class AddCoursesOpen < ActiveRecord::Migration[6.0]
  def change
    add_column :course_choices, :open, :boolean, required: true
  end
end
