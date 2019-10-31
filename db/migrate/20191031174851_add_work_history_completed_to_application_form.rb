class AddWorkHistoryCompletedToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :work_history_completed, :boolean, default: false, null: false
  end
end
