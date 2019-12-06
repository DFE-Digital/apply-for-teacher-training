class AddSupportUsersEmailAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :support_users, :email_address, :string, null: false
  end
end
