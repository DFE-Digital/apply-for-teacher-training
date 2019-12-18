class AddAcceptedTsAndCsAtToProviderUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users, :accepted_ts_and_cs_at, :datetime
  end
end
