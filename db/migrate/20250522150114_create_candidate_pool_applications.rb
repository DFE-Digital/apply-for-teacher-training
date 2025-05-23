class CreateCandidatePoolApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_pool_applications do |t|
      t.references :application_form, null: false, foreign_key: { on_delete: :cascade }
      t.references :candidate, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end
