class RenameEnglishLanguageProficiency < ActiveRecord::Migration[6.0]
  def change
    rename_table :english_language_proficiencies, :english_proficiencies
  end
end
