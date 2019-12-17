class AddTimestampsToProviderUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :provider_users, &:timestamps
  end
end
