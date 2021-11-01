class MonthlyStatisticsController < ApplicationController
  def show
    @statistics = MonthlyStatisticsReport.last.statistics
    @candidates_export = DataExport.where(export_type: 'external_report_candidates').order(:created_at).last
    @applications_export = DataExport.where(export_type: 'external_report_applications').order(:created_at).last
  end
end
