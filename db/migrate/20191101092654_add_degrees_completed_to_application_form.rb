class AddDegreesCompletedToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :degrees_completed, :boolean, default: false, null: false
  end
end
