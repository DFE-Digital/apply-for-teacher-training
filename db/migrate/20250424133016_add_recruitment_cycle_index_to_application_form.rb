class AddRecruitmentCycleIndexToApplicationForm < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :application_forms, :recruitment_cycle_year, algorithm: :concurrently
  end
end
