class MakeTimeframesSti < ActiveRecord::Migration[5.2]
  def change
    add_column :timeframes, :type, :string
    rename_column :timeframes, :number_of_working_days_until_rejection, :number_of_working_days
  end
end
