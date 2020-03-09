class AddSafeguardingConcernsToReference < ActiveRecord::Migration[6.0]
  def change
    change_table :references, bulk: true do |t|
      t.column :safeguarding_concerns, :string
      t.column :relationship_correction, :string
    end
  end
end
