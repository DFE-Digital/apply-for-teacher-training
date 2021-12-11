module Publications
  class MonthlyStatisticsController < ApplicationController
    before_action :redirect_unless_published

    def show
      @presenter = Publications::MonthlyStatisticsPresenter.new(
        MonthlyStatisticsTimetable.current_report,
      )
      @monthly_statistics_report = MonthlyStatisticsTimetable.current_report
      @statistics = @monthly_statistics_report.statistics
      @academic_year_name = RecruitmentCycle.cycle_name(CycleTimetable.next_year)
      @current_cycle_name = RecruitmentCycle.verbose_cycle_name
    end

    def download
      # data_export = DataExport.find_by(export_type: params[:export_type])
      # data_export.update(audit_comment: 'File downloaded')
      # send_data data_export.data, filename: data_export.month_filename, disposition: :attachment

      export_type = params[:export_type]
      export_filename = "#{export_type}-#{params[:date]}.csv"
      data = MonthlyStatisticsTimetable.current_report.statistics[export_type]
      send_data data, filename: export_filename, disposition: :attachment
    end

    def redirect_unless_published
      redirect_to root_path unless FeatureFlag.active?(:publish_monthly_statistics)
    end
  end
end
