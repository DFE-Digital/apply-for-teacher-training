class CreateCandidateInterfacePreferences < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_preferences do |t|
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }
      t.string :pool_status, null: false, default: 'opt_out'
      t.string :status, null: false, default: 'draft'
      t.boolean :dynamic_location_preferences, null: false, default: false

      t.timestamps
    end
  end
end
