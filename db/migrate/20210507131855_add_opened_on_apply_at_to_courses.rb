class AddOpenedOnApplyAtToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :opened_on_apply_at, :datetime
  end
end
