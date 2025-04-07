class AddProviderToLocationPreference < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_reference :candidate_location_preferences, :provider, null: true, index: { algorithm: :concurrently }
  end
end
