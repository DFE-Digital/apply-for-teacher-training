class CreateCandidatePreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_preferences do |t|
      t.string :pool_status
      t.string :status, null: false, default: 'draft'
      t.boolean :dynamic_location_preferences
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
