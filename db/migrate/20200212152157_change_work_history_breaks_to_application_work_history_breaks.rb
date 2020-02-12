class ChangeWorkHistoryBreaksToApplicationWorkHistoryBreaks < ActiveRecord::Migration[6.0]
  def change
    rename_table :work_history_breaks, :application_work_history_breaks
  end
end
