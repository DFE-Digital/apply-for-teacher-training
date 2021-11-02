class AddApplicationsOpenFromToCourse < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :courses, :applications_open_from, :datetime
    add_index :courses, :applications_open_from, unique: true, algorithm: :concurrently
  end
end
