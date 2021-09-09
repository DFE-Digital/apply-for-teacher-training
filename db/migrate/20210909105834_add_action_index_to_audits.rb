class AddActionIndexToAudits < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!

  def up
    safety_assured { execute 'SET statement_timeout = 0' }
    add_index :audits, %i[auditable_type auditable_id action], if_not_exists: true, algorithm: :concurrently
  end

  def down
    safety_assured { execute 'SET statement_timeout = 0' }
    remove_index :audits, column: %i[auditable_type auditable_id action], if_exists: true, algorithm: :concurrently
  end
end
