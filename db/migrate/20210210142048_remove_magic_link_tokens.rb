class RemoveMagicLinkTokens < ActiveRecord::Migration[6.0]
  def change
    remove_column :provider_users, :magic_link_token, :string
    remove_column :provider_users, :magic_link_token_sent_at, :datetime
  end
end
