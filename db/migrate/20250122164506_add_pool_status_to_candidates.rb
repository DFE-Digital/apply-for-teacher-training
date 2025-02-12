class AddPoolStatusToCandidates < ActiveRecord::Migration[8.0]
  def change
    add_column :candidates, :pool_status, :string, null: false, default: 'not_set'
  end
end
