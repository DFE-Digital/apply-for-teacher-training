class AddCandidatesAccountLocked < ActiveRecord::Migration[6.1]
  def change
    add_column :candidates, :account_locked, :boolean, null: false, default: false
  end
end
