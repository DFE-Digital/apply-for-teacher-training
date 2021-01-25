class AddWorkHistoryStatusToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :work_history_status, :string
  end
end
