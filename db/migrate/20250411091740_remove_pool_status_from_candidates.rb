class RemovePoolStatusFromCandidates < ActiveRecord::Migration[8.0]
  def change
    safety_assured do
      remove_column :candidates, :pool_status, :string, null: false, default: 'not_set'
    end
  end
end
