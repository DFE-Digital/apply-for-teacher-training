class RemoveProviderCodeFromCourses < ActiveRecord::Migration[5.2]
  def change
    remove_column :courses, :provider_code, :string
  end
end
