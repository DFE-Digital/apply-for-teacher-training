class AddIndexesToProviderIdAndProviderUserId < ActiveRecord::Migration[6.0]
  def change
    add_index(:provider_users_providers, %i[provider_id provider_user_id], unique: true, name: 'index_provider_users_providers_by_provider_and_provider_user')
  end
end
