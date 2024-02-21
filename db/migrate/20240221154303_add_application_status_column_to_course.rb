class AddApplicationStatusColumnToCourse < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :application_status, :integer, default: 0, null: false
  end
end
