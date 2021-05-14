class AddAuditsAuditedChangesIndex < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    return if index_exists?(:audits, :audited_changes)

    safety_assured { execute 'SET statement_timeout = 0' }
    add_index :audits, :audited_changes, using: :gin, algorithm: :concurrently
  end

  def down
    return unless index_exists?(:audits, :audited_changes)

    safety_assured { execute 'SET statement_timeout = 0' }
    remove_index :audits, column: :audited_changes, algorithm: :concurrently
  end
end
