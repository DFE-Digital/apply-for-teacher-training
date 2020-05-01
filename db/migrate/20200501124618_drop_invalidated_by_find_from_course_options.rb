class DropInvalidatedByFindFromCourseOptions < ActiveRecord::Migration[6.0]
  def up
    remove_column :course_options, :invalidated_by_find
  end

  def down
    change_table :course_options do |table|
      table.column :invalidated_by_find, :boolean, default: false
    end
  end
end
