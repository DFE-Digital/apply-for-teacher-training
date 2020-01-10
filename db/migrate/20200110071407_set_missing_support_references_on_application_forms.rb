class SetMissingSupportReferencesOnApplicationForms < ActiveRecord::Migration[6.0]
  def up
    ApplicationForm.where(support_reference: nil).each do |form|
      form.update(support_reference: GenerateSupportRef.call)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
