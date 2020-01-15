class UpcasePostcodesOnApplicationForms < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      UPDATE
        application_forms
      SET
        postcode = UPPER(postcode)
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
