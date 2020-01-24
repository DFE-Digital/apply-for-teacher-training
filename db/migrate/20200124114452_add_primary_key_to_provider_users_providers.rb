class AddPrimaryKeyToProviderUsersProviders < ActiveRecord::Migration[6.0]
  def change
    change_table :provider_users_providers, bulk: false do |t|
      t.primary_key :id
      t.datetime :created_at, null: false, default: -> { 'current_timestamp' }
      t.datetime :updated_at, null: false, default: -> { 'current_timestamp' }
    end
  end
end
