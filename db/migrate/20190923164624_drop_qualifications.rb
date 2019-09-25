class DropQualifications < ActiveRecord::Migration[5.2]
  def up
    drop_table :qualifications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
