class AddSignInCountToCandidate < ActiveRecord::Migration[6.0]
  def change
    add_column :candidates, :sign_in_count, :integer, default: 0, null: false
  end
end
