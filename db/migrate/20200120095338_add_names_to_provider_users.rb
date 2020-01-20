class AddNamesToProviderUsers < ActiveRecord::Migration[6.0]
  def change
    change_table :provider_users, bulk: true do |t|
      t.column :first_name, :string
      t.column :last_name, :string
    end
  end
end
