class AddInvalidatedByFindToCourseOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :course_options, :invalidated_by_find, :boolean, default: false
  end
end
