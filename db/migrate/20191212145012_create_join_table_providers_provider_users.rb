class CreateJoinTableProvidersProviderUsers < ActiveRecord::Migration[6.0]
  def change
    create_join_table :providers, :provider_users do |t|
      t.index :provider_id
      t.index :provider_user_id
    end
  end
end
