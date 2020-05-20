class AddEditByToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :edit_by, :datetime
  end
end
