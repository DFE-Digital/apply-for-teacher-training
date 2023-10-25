class AddEditableUntilToApplicationForms < ActiveRecord::Migration[7.0]
  def change
    add_column :application_forms, :editable_until, :datetime
  end
end
