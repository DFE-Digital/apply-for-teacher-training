class AddGetApplicationsIndexesToApplicationChoice < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :application_choices, :provider_ids, using: 'gin', if_not_exists: true, algorithm: :concurrently
    add_index :application_choices, :current_recruitment_cycle_year, if_not_exists: true, algorithm: :concurrently
  end
end
