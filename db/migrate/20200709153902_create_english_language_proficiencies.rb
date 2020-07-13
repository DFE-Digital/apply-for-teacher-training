class CreateEnglishLanguageProficiencies < ActiveRecord::Migration[6.0]
  def change
    create_table :english_language_proficiencies do |t|
      t.belongs_to :application_form, null: false, index: { unique: true }
      t.belongs_to :efl_qualification, polymorphic: true, index: { name: 'index_elp_on_efl_qualification_type_and_id' }

      t.timestamps
    end
  end
end
