class AddDuplicateBooleanToReferences < ActiveRecord::Migration[6.0]
  def change
    add_column :references, :duplicate, :boolean, default: false
  end
end
