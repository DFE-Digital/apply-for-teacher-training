class AddRecruitmentCycleYearToPerformanceReports < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_column :national_recruitment_performance_reports, :recruitment_cycle_year, :integer
    add_column :provider_recruitment_performance_reports, :recruitment_cycle_year, :integer

    add_index :provider_recruitment_performance_reports, :recruitment_cycle_year, algorithm: :concurrently
    add_index :national_recruitment_performance_reports, :recruitment_cycle_year, algorithm: :concurrently
  end
end
