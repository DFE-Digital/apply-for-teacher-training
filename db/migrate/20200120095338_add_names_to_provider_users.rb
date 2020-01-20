class AddNamesToProviderUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :provider_users, :first_name, :string
    add_column :provider_users, :last_name, :string
  end
end
