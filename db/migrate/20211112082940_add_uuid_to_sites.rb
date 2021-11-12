class AddUuidToSites < ActiveRecord::Migration[6.1]
  def change
    add_column :sites, :uuid, :uuid
  end
end
