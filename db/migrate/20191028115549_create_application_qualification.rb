class CreateApplicationQualification < ActiveRecord::Migration[6.0]
  def change
    create_table :application_qualifications do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }

      t.string :level, null: false
      t.string :qualification_type, null: false
      t.string :subject, null: false
      t.string :grade, null: false
      t.boolean :predicted_grade, null: false
      t.string :award_year, null: false
      t.string :institution_name
      t.string :institution_country
      t.string :awarding_body
      t.string :equivalency_details

      t.timestamps
    end
  end
end
