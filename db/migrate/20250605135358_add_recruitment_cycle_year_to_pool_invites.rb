class AddRecruitmentCycleYearToPoolInvites < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :pool_invites, :recruitment_cycle_year, :integer
    add_index :pool_invites, :recruitment_cycle_year, algorithm: :concurrently
  end
end
