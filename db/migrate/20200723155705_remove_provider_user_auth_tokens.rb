class RemoveProviderUserAuthTokens < ActiveRecord::Migration[6.0]
  def change
    remove_column :provider_users, :magic_link_token, :string, unique: true
    remove_column :provider_users, :magic_link_token_sent_at, :datetime
  end
end
