class AddContactDetailsToApplicationForm < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :phone_number, :string
    add_column :application_forms, :address_line1, :string
    add_column :application_forms, :address_line2, :string
    add_column :application_forms, :address_line3, :string
    add_column :application_forms, :address_line4, :string
    add_column :application_forms, :country, :string
    add_column :application_forms, :postcode, :string
  end
end
