class AddProvidersRegionCode < ActiveRecord::Migration[6.0]
  def change
    change_table :providers, bulk: true do |t|
      t.string :region_code
    end
  end
end
