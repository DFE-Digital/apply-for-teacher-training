class AddProviderSyncCourses < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :sync_courses, :boolean, null: false, default: false

    Provider.reset_column_information
    Provider.find_each do |provider|
      provider.update(sync_courses: true) if provider.courses.count.positive?
    end
  end
end
