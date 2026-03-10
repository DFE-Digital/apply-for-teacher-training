class AddCycleToRegionalReportFilter < ActiveRecord::Migration[8.0]
  def change
    add_column :regional_report_filters, :recruitment_cycle_year, :integer
  end
end
