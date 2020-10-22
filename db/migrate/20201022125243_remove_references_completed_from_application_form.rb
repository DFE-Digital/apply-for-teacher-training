class RemoveReferencesCompletedFromApplicationForm < ActiveRecord::Migration[6.0]
  def up
    remove_column :application_forms, :references_completed
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
