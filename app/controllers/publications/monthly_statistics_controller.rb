module Publications
  class MonthlyStatisticsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def show
      redirect_to publications_monthly_statistics_temporarily_unavailable_path if params[:year].to_i == RecruitmentCycle.current_year

      @presenter = Publications::MonthlyStatisticsPresenter.new(current_report)
      @csv_export_types_and_sizes = calculate_download_sizes(current_report)
    end

    def download
      export_type = params[:export_type]
      export_filename = "#{export_type}-#{params[:month]}.csv"
      raw_data = current_report.statistics[export_type]
      header_row = raw_data['rows'].first.keys
      data = SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
      send_data data, filename: export_filename, disposition: :attachment
    end

    def calculate_download_sizes(report)
      report.statistics.map do |k, raw_data|
        next unless raw_data.is_a?(Hash)

        header_row = raw_data['rows'].first.keys
        data = SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
        [k, data.size]
      end.compact
    end

    def temporarily_unavailable; end

  private

    def current_report
      return MonthlyStatisticsTimetable.report_for_current_period if params[:month].blank? && params[:year].blank?

      if params[:year].present?
        MonthlyStatisticsTimetable.report_for_latest_in_cycle(params[:year].to_i)
      else
        MonthlyStatisticsTimetable.current_report_at(Date.parse("#{params[:month]}-01"))
      end
    rescue Date::Error
      raise ActiveRecord::RecordNotFound
    end
  end
end
