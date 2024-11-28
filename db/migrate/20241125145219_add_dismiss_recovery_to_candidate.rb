class AddDismissRecoveryToCandidate < ActiveRecord::Migration[8.0]
  def change
    add_column :candidates, :dismiss_recovery, :boolean, default: false
  end
end
