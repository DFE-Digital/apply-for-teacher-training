class AddOpenOnApplyToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :open_on_apply, :boolean, default: true, null: false
    add_index :courses, %i[exposed_in_find open_on_apply]
  end
end
