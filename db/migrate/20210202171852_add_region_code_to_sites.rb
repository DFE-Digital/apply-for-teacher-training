class AddRegionCodeToSites < ActiveRecord::Migration[6.0]
  def change
    add_column :sites, :region, :string
  end
end
