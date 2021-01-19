class RemoveReceivedAtFromReferences < ActiveRecord::Migration[6.0]
  def change
    remove_column :references, :received_at, :datetime
  end
end
