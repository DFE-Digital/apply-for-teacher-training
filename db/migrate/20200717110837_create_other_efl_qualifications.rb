class CreateOtherEflQualifications < ActiveRecord::Migration[6.0]
  def change
    create_table :other_efl_qualifications do |t|
      t.string :name, null: false
      t.string :grade, null: false
      t.integer :award_year, null: false

      t.timestamps
    end
  end
end
