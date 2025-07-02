class AddRejectedProviderIdsToCandidatePoolApplication < ActiveRecord::Migration[8.0]
  def change
    add_column :candidate_pool_applications, :rejected_provider_ids, :bigint, array: true, null: false, default: []
  end
end
