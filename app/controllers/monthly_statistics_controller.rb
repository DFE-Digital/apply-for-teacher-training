class MonthlyStatisticsController < ApplicationController
  def show
    @statistics = MonthlyStatisticsReport.last.statistics
    @applications_export = DataExport.where(export_type: 'external_report_applications').order(:created_at).last
  end
end
