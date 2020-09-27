class AddForceOpenToCourseOptions < ActiveRecord::Migration[6.0]
  def change
    add_column :course_options, :hold_open, :boolean, null: false, default: false
  end
end
