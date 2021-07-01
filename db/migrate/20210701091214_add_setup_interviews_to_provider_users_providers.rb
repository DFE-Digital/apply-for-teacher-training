class AddSetupInterviewsToProviderUsersProviders < ActiveRecord::Migration[6.1]
  def change
    add_column :provider_users_providers, :setup_interviews, :boolean, default: false, null: false
  end
end
