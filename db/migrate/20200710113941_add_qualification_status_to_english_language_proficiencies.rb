class AddQualificationStatusToEnglishLanguageProficiencies < ActiveRecord::Migration[6.0]
  def change
    add_column :english_language_proficiencies, :qualification_status, :string, null: false
  end
end
