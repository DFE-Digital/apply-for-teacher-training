module Publications
  module V2
    class MonthlyStatisticsController < ApplicationController
      def show
        @presenter = MonthlyStatisticsPresenter.new(current_report)
      end

      def download
        return not_found unless csv_exists?

        export_filename = "#{export_type}-#{month}.csv"

        send_data current_report_csv['data'], filename: export_filename, disposition: :attachment
      end

    private

      def csv_exists?
        current_report_csv.present?
      end

      def export_type
        params[:export_type]
      end

      def month
        params[:month]
      end

      def current_report_csv
        current_report.statistics['formats']['csv'][export_type]
      end

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
