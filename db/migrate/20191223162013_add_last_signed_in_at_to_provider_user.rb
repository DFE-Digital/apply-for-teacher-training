class AddLastSignedInAtToProviderUser < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users, :last_signed_in_at, :datetime
  end
end
