class AddAddressToSite < ActiveRecord::Migration[6.0]
  def change
    add_column :sites, :address_line1, :string
    add_column :sites, :address_line2, :string
    add_column :sites, :address_line3, :string
    add_column :sites, :address_line4, :string
    add_column :sites, :postcode, :string
  end
end
