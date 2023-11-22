module Publications
  module MonthlyStatistics
    module V1
      class CalculateDownloadSizes
        attr_reader :report

        def initialize(report)
          @report = report
        end

        def call
          report.statistics.map do |k, raw_data|
            next unless raw_data.is_a?(Hash)

            header_row = raw_data['rows'].first.keys
            data = SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
            [k, data.size]
          end.compact
        end
      end
    end
  end
end
