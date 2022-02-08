module Publications
  module MonthlyStatistics
    class JSONExport
      attr_reader :filename, :folder

      def initialize(filename)
        @filename = filename.presence || 'monthly_report.json'
      end

      def import!(month)
        json = File.read(@filename)

        raise "#{@filename} not found" if json.blank?

        Publications::MonthlyStatistics::MonthlyStatisticsReport.create!(
          statistics: JSON.parse(json),
          month: month,
        )
      end

      def export!
        report = Publications::MonthlyStatistics::MonthlyStatisticsReport.last
        stats = report.statistics
        File.write(@filename, stats.to_json)

        @folder = "tmp/#{Time.zone.today}-xr-#{report.month}"

        `mkdir #{@folder}`

        stats.keys.reject { |k| k == 'deferred_applications_count' }.each do |table|
          raw_data = stats[table]
          header_row = raw_data['rows'].first.keys
          data = SafeCSV.generate(raw_data['rows'].map(&:values), header_row)
          File.write("#{@folder}/#{table}.csv", data)
        end
      end
    end
  end
end
