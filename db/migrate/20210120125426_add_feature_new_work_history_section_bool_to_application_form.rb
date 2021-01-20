class AddFeatureNewWorkHistorySectionBoolToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :feature_restructured_work_history, :boolean, default: true
  end
end
