class RenameTypeColumnInRefereeTable < ActiveRecord::Migration[6.0]
  def change
    rename_column :references, :type, :referee_type
  end
end
