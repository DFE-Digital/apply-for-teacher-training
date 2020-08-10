class AddCycleToApplicationForms < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :cycle, :integer, default: 2020
  end
end
