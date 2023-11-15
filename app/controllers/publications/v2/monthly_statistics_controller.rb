module Publications
  module V2
    class MonthlyStatisticsController < ApplicationController
      def show
        @presenter = MonthlyStatisticsPresenter.new(current_report)
        @csv_export_types_and_sizes = calculate_download_sizes(@presenter)
      end

      # TODO: Downloads
      def download
        # export_type = params[:export_type]
        # export_filename = "#{export_type}-#{params[:month]}.csv"
        # raw_data = current_report.statistics[export_type]
        # header_row = raw_data['rows'].first.keys
        # data = SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
        # send_data data, filename: export_filename, disposition: :attachment
      end

      def calculate_download_sizes(_report)
        []
        # cache 'data_sizes' do
        #   report.statistics.map do |k, raw_data|
        #     next unless raw_data.is_a?(Hash)
        #
        #     header_row = raw_data['rows'].first.keys
        #     data = SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
        #     [k, data.size]
        #   end.compact
        # end
      end

    private

      # TODO: This will be split into many actions in this controller
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
end
