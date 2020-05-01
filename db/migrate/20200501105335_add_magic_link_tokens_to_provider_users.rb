class AddMagicLinkTokensToProviderUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users, :magic_link_token, :string, unique: true
    add_column :provider_users, :magic_link_token_sent_at, :datetime
  end
end
