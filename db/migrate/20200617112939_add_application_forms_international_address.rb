class AddApplicationFormsInternationalAddress < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :address_type, :string, null: false, default: 'uk'
    add_column :application_forms, :international_address, :string
  end
end
