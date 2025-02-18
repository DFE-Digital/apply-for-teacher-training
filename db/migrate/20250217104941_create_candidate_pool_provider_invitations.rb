class CreateCandidatePoolProviderInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :candidate_pool_provider_invitations do |t|
      t.references :provider, null: false, foreign_key: true
      t.timestamps
    end
  end
end
