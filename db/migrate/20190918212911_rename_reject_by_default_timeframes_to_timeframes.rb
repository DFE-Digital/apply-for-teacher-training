class RenameRejectByDefaultTimeframesToTimeframes < ActiveRecord::Migration[5.2]
  def change
    rename_table :reject_by_default_timeframes, :timeframes
  end
end
