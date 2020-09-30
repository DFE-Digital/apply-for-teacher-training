class RemoveValidationOnRefereesEmailAddress < ActiveRecord::Migration[6.0]
  def up
    change_column :references, :email_address, :string, null: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
