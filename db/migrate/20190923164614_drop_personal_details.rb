class DropPersonalDetails < ActiveRecord::Migration[5.2]
  def up
    drop_table :personal_details
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
