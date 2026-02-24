class RemoveEnglishLanguageProficienciesApplicationFormIdUniqueIndex < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    if index_exists?(:english_proficiencies, :application_form_id)
      remove_index :english_proficiencies, :application_form_id
    end
    add_index :english_proficiencies, :application_form_id, algorithm: :concurrently
  end

  def down
    if index_exists?(:english_proficiencies, :application_form_id)
      remove_index :english_proficiencies, :application_form_id
    end
    add_index :english_proficiencies, :application_form_id, unique: true, algorithm: :concurrently
  end
end
