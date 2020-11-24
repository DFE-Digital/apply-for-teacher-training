class AddSitesLatitudeAndLongitude < ActiveRecord::Migration[6.0]
  def change
    add_column :sites, :latitude, :float
    add_column :sites, :longitude, :float
  end
end
