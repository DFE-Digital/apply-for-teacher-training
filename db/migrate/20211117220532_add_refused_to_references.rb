class AddRefusedToReferences < ActiveRecord::Migration[6.1]
  def change
    add_column :references, :refused, :boolean
  end
end
