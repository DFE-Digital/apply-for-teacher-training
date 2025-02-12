class CreateCandidatePoolProviderOptIns < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_pool_provider_opt_ins do |t|
      t.references :provider, null: false, foreign_key: { on_delete: :cascade }
      t.timestamps
    end
  end
end
