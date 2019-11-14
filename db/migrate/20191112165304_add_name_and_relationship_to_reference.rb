class AddNameAndRelationshipToReference < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :name, :string
    add_column :references, :relationship, :string
  end
end
