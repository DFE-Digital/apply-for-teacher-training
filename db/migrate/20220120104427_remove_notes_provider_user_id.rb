class RemoveNotesProviderUserId < ActiveRecord::Migration[6.1]
  def up
    safety_assured { remove_column :notes, :provider_user_id }
  end
end
