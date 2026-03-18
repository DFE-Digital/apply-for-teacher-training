class RemoveQualificationStatusNotNullConditionFromEnglishProficiencies < ActiveRecord::Migration[8.0]
  def up
    change_column :english_proficiencies, :qualification_status, :string, null: true
  end

  def down
    change_column :english_proficiencies, :qualification_status, :string, null: false
  end
end
