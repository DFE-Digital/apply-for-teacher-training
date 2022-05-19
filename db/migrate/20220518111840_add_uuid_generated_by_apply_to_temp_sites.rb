class AddUuidGeneratedByApplyToTempSites < ActiveRecord::Migration[7.0]
  def change
    add_column :temp_sites, :uuid_generated_by_apply, :boolean, default: false
  end
end
