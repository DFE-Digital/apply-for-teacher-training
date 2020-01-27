class AddLastSignedInAtToCandidate < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :last_signed_in_at, :datetime
  end
end
