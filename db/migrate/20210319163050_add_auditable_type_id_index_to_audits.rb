class AddAuditableTypeIdIndexToAudits < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def change
    add_index :audits, %i[auditable_type id], algorithm: :concurrently
  end
end
