class DropDegrees < ActiveRecord::Migration[5.2]
  def up
    drop_table :degrees
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
