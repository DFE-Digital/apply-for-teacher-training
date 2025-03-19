class CreateCandidateLocationPreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_location_preferences do |t|
      t.string :name, null: false
      t.integer :within, null: false
      t.float :latitude
      t.float :longitude
      t.string :status, null: false, default: 'draft'
      t.references :candidate_preference, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
