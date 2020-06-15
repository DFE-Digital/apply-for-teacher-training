class CreateDraftDegrees < ActiveRecord::Migration[6.0]
  def change
    create_table :draft_degrees do |t|
      t.string :degree_type
      t.string :subject
      t.string :institution_name
      t.string :grade
      t.boolean :predicted_grade
      t.string :start_year
      t.string :award_year
      t.references :application_form, null: false, foreign_key: true

      t.timestamps
    end
  end
end
