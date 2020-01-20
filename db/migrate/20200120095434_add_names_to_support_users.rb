class AddNamesToSupportUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :support_users, :first_name, :string
    add_column :support_users, :last_name, :string
  end
end
