class AddStatusToVendors < ActiveRecord::Migration[8.1]
  def change
    add_column :vendors, :status, :string, default: 'unconfirmed', null: false
  end
end
