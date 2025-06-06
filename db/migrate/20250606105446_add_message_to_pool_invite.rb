class AddMessageToPoolInvite < ActiveRecord::Migration[8.0]
  def change
    add_column(:pool_invites, :invite_message, :boolean)
    add_column(:pool_invites, :message, :text)
  end
end
