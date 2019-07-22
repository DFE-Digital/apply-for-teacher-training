class AddAddressToPersonalDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :personal_details, :address, :string
  end
end
