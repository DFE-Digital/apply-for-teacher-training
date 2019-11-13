class AddExposedInFindToCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :courses, :exposed_in_find, :boolean
  end
end
