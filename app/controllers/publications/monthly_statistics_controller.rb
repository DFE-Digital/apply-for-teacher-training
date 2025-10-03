module Publications
  class MonthlyStatisticsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    before_action MonthlyStatisticsRedirectFilter, only: %i[index by_month download by_year]

    def index
      @current_timetable = RecruitmentCycleTimetable.current_timetable
      @previous_timetable = @current_timetable.relative_previous_timetable
    end

    def by_month
      @report = MonthlyStatistics::MonthlyStatisticsReport.published.find_by!(month:)

      render_report
    end

    def by_year
      if params[:year].to_i.in? RecruitmentCycleTimetable.pluck(:recruitment_cycle_year)
        @report = MonthlyStatistics::MonthlyStatisticsReport.report_for_latest_in_cycle(params[:year].to_i)
        render_report
      else
        render 'errors/not_found', status: :not_found, formats: :html
      end
    end

    def download
      @report = MonthlyStatistics::MonthlyStatisticsReport.published.find_by!(month:)

      return render 'errors/not_found', status: :not_found, formats: :html unless csv.exists?

      send_data csv.data, filename: csv.filename, disposition: :attachment
    end

    def temporarily_unavailable; end

  private

    def render_report
      if @report.v2?
        @presenter = Publications::V2::MonthlyStatisticsPresenter.new(@report)
        render 'publications/monthly_statistics/v2/show'
      else
        @presenter = Publications::V1::MonthlyStatisticsPresenter.new(@report)
        @csv_export_types_and_sizes = MonthlyStatistics::V1::CalculateDownloadSizes.new(@report).call
        render 'publications/monthly_statistics/v1/show'
      end
    end

    def csv
      @csv ||= csv_klass.new(report: @report, export_type: params[:export_type])
    end

    def csv_klass
      if @report.v2?
        ::Publications::MonthlyStatistics::V2::ExportCSV
      else
        ::Publications::MonthlyStatistics::V1::ExportCSV
      end
    end

    def month
      params.expect(:month)
    rescue Date::Error
      raise ActiveRecord::RecordNotFound
    end
  end
end
