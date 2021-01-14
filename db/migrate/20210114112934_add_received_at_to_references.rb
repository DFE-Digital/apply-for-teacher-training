class AddReceivedAtToReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :received_at, :datetime
  end
end
