class AddProviderIdToCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :courses, :provider_id, :integer
  end
end
