class DowncaseProviderAndSupportEmails < ActiveRecord::Migration[6.0]
  def change
    ProviderUser.find_each do |provider_user|
      provider_user.update!(email_address: provider_user.email_address)
    end

    add_index :support_users, :email_address, unique: true
    SupportUser.find_each do |support_user|
      support_user.update!(email_address: support_user.email_address)
    end
  end
end
