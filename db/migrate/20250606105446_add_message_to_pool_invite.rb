class AddMessageToPoolInvite < ActiveRecord::Migration[8.0]
  def change
    add_column(:pool_invites, :provider_message, :boolean)
    add_column(:pool_invites, :message_content, :text)
  end
end
