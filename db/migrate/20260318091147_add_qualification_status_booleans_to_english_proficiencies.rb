class AddQualificationStatusBooleansToEnglishProficiencies < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :english_proficiencies, :has_qualification, :boolean, null: false, default: false
    add_column :english_proficiencies, :no_qualification, :boolean, null: false, default: false
    add_column :english_proficiencies, :qualification_not_needed, :boolean, null: false, default: false
    add_column :english_proficiencies, :degree_taught_in_english, :boolean, null: false, default: false
    add_column :english_proficiencies, :draft, :boolean, null: true, default: true

    add_index :english_proficiencies, :has_qualification, algorithm: :concurrently
    add_index :english_proficiencies, :no_qualification, algorithm: :concurrently
    add_index :english_proficiencies, :qualification_not_needed, algorithm: :concurrently
    add_index :english_proficiencies, :degree_taught_in_english, algorithm: :concurrently
    add_index :english_proficiencies, :draft, algorithm: :concurrently
  end
end
