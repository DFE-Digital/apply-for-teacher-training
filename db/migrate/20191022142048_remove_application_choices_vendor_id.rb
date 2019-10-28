class RemoveApplicationChoicesVendorId < ActiveRecord::Migration[6.0]
  def change
    remove_column :application_choices, :vendor_id, :string, limit: 10, null: false
  end
end
