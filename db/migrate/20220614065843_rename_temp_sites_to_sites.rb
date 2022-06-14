class RenameTempSitesToSites < ActiveRecord::Migration[7.0]
  def change
    rename_index :temp_sites, 'index_temp_sites_on_provider_id', 'index_sites_on_provider_id'
    rename_index :temp_sites, 'index_temp_sites_on_uuid_and_provider_id', 'index_sites_on_uuid_and_provider_id'
  end
end
