class AddAuditsAuditedChangesIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :audits, :audited_changes, using: :gin, algorithm: :concurrently
  end
end
