class AddDismissRecoveryToCandidate < ActiveRecord::Migration[8.0]
  def change
    add_column :candidates, :dismiss_recovery, :boolean, default: false
    add_column :candidates, :recovered, :boolean, default: false
  end
end
