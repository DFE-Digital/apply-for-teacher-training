class RemoveQualificationStatusFromEnglishProficiencies < ActiveRecord::Migration[8.1]
  def change
    safety_assured { remove_column :english_proficiencies, :qualification_status, :string }
  end
end
