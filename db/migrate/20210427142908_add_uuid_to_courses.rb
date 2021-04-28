class AddUuidToCourses < ActiveRecord::Migration[6.1]
  def change
    add_column :courses, :uuid, :uuid
  end
end
