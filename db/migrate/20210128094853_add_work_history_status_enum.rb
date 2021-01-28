class AddWorkHistoryStatusEnum < ActiveRecord::Migration[6.0]
  def up
    remove_column :application_forms, :work_history_status, :string
    create_enum 'work_history_type', %w[can_complete full_time_education can_not_complete]
    add_column :application_forms, :work_history_status, :work_history_type
  end

  def down
    remove_column :application_forms, :work_history_status, :string
    drop_enum 'work_history_type'
    add_column :application_forms, :work_history_status, :string
  end
end
