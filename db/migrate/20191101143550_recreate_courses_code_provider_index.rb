class RecreateCoursesCodeProviderIndex < ActiveRecord::Migration[6.0]
  def change
    remove_index :courses, :code
    add_index :courses, :code
    add_index :courses, %i[provider_id code], unique: true
  end
end
