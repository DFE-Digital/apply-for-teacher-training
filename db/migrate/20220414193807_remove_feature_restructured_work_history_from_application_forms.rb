class RemoveFeatureRestructuredWorkHistoryFromApplicationForms < ActiveRecord::Migration[7.0]
  def change
    safety_assured { remove_column :application_forms, :feature_restructured_work_history, :boolean }
  end
end
