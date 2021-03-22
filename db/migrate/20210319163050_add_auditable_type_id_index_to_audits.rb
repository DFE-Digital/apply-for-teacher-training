class AddAuditableTypeIdIndexToAudits < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    return if index_exists?(:audits, %i[auditable_type id])

    execute 'SET statement_timeout = 0'
    add_index :audits, %i[auditable_type id], algorithm: :concurrently
  end

  def down
    return unless index_exists?(:audits, %i[auditable_type id])

    execute 'SET statement_timeout = 0'
    remove_index :audits, column: %i[auditable_type id], algorithm: :concurrently
  end
end
