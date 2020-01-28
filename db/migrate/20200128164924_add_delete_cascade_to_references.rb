class AddDeleteCascadeToReferences < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key :references, :application_forms
    add_foreign_key :references, :application_forms, on_delete: :cascade
  end

  def down
    remove_foreign_key :references, :application_forms
    add_foreign_key :references, :application_forms, on_delete: :restrict
  end
end
