class AddScienceGcseCompletedToApplicationForms < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :science_gcse_completed, :boolean, default: false
  end
end
