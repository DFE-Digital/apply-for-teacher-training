class DropContactDetails < ActiveRecord::Migration[5.2]
  def up
    drop_table :contact_details
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
