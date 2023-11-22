module Publications
  module MonthlyStatistics
    module V2
      class ExportCSV
        attr_accessor :report, :export_type

        def initialize(report:, export_type:)
          @report = report
          @export_type = export_type
        end

        def data
          report_csv['data']
        end

        def exists?
          report_csv.present?
        end

        def filename
          "#{export_type}-#{@report.month}.csv"
        end

      private

        def report_csv
          @report.statistics['formats']['csv'][export_type]
        end
      end
    end
  end
end
