class AddConfidentialToReferences < ActiveRecord::Migration[8.0]
  def change
    add_column :references, :confidential, :boolean, default: true, null: false
  end
end
