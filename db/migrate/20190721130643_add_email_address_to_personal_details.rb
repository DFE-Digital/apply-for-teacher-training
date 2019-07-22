class AddEmailAddressToPersonalDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :personal_details, :email_address, :string
  end
end
