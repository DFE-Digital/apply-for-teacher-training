class AddLatLongToApplicationForms < ActiveRecord::Migration[6.0]
  def change
    add_column :application_forms, :latitude, :float
    add_column :application_forms, :longitude, :float
  end
end
