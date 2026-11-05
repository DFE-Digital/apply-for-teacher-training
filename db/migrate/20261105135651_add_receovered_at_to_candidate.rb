class AddReceoveredAtToCandidate < ActiveRecord::Migration[8.1]
  def change
    add_column :candidates, :recovered_at, :datetime
  end
end
