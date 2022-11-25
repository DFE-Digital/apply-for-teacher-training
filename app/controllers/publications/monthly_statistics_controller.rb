module Publications
  class MonthlyStatisticsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def show
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

  private

    def current_report
      return MonthlyStatisticsTimetable.report_for_current_period unless params[:month].present?

      if itt_match.present?
        recruitment_cycle_year = itt_match[1].to_i
        return MonthlyStatisticsTimetable.report_for_current_period if CycleTimetable.current_year == recruitment_cycle_year

        month = latest_month_for(recruitment_cycle_year)
      else
        month = params[:month]
      end

      MonthlyStatisticsTimetable.current_report_at(Date.parse("#{month}-01"))
    end

    def itt_match
      /^ITT([0-9]{4})/.match(params[:month])
    end

    def latest_month_for(recruitment_cycle_year)
      period = CycleTimetable.find_closes(recruitment_cycle_year) - 1.month
      [period.year, period.month].join('-')
    end
  end
end
