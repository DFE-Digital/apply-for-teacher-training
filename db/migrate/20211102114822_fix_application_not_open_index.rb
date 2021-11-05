class FixApplicationNotOpenIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    remove_index :courses, :applications_open_from
    add_index :courses, :applications_open_from, algorithm: :concurrently
  end
end
