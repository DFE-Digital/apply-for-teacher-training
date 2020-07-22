class AddNoQualificationDetailsToEnglishProficiencies < ActiveRecord::Migration[6.0]
  def change
    add_column :english_proficiencies, :no_qualification_details, :text
  end
end
