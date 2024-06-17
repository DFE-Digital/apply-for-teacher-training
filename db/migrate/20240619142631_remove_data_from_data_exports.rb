class RemoveDataFromDataExports < ActiveRecord::Migration[7.1]
  def change
    safety_assured do
      remove_column :data_exports, :data, :binary
    end
  end
end
