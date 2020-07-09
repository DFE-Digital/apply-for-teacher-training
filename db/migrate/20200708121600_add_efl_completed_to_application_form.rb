class AddEflCompletedToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :efl_completed, :boolean, default: false
  end
end
