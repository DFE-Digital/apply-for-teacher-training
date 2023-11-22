module Publications
  module MonthlyStatistics
    module V1
      class ExportCSV
        attr_accessor :report, :export_type

        def initialize(report:, export_type:)
          @report = report
          @export_type = export_type
        end

        def data
          SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
        end

        def exists?
          raw_data.present?
        end

        def filename
          "#{@export_type}-#{@report.month}.csv"
        end

      private

        def header_row
          raw_data['rows'].first.keys
        end

        def raw_data
          @raw_data ||= report.statistics[@export_type]
        end
      end
    end
  end
end
