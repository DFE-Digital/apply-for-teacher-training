class AddCandidateRecruitmentCycleIndexToApplications < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!

  def change
    add_index :application_forms, [:recruitment_cycle_year, :candidate_id], unique: true, algorithm: :concurrently
  end
end
