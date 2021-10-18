class AddApplicationFormsRegionCode < ActiveRecord::Migration[6.1]
  def change
    add_column :application_forms, :region_code, :string
  end
end
