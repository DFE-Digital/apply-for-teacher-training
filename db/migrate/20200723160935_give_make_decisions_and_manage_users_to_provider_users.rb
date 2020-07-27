class GiveMakeDecisionsAndManageUsersToProviderUsers < ActiveRecord::Migration[6.0]
  def up
    LaunchMakeDecisionsAndManageUsers.new.update_provider_user_permissions!
  end

  def down; end
end
