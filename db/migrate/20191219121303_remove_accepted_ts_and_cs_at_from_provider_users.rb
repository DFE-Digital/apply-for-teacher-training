class RemoveAcceptedTsAndCsAtFromProviderUsers < ActiveRecord::Migration[6.0]
  def change
    remove_column :provider_users, :accepted_ts_and_cs_at, :datetime
  end
end
