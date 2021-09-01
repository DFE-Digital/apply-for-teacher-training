class AddGetApplicationsIndexesToApplicationChoice < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    safety_assured { execute 'SET statement_timeout = 0' }
    add_index :application_choices, :provider_ids, using: 'gin', if_not_exists: true, algorithm: :concurrently
    add_index :application_choices, :current_recruitment_cycle_year, if_not_exists: true, algorithm: :concurrently
  end

  def down
    safety_assured { execute 'SET statement_timeout = 0' }
    remove_index :application_choices, :provider_ids, if_exists: true, algorithm: :concurrently
    remove_index :application_choices, :current_recruitment_cycle_year, if__exists: true, algorithm: :concurrently
  end
end
