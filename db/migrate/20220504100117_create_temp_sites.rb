class CreateTempSites < ActiveRecord::Migration[7.0]
  def change
    create_table :temp_sites do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :uuid
      t.references :provider, null: false, foreign_key: true
      t.string :address_line1
      t.string :address_line2
      t.string :address_line3
      t.string :address_line4
      t.string :postcode
      t.float :latitude
      t.float :longitude
      t.string :region

      t.timestamps
    end

    add_index :temp_sites, %i[uuid provider_id], unique: true
  end
end
