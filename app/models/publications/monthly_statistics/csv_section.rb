module Publications
  module MonthlyStatistics
    class CSVSection
      attr_reader :section, :section_identifier, :section_data

      def initialize(section_identifier:, section:)
        @section = section
        @section_identifier = section_identifier
        @section_data = section[:data]
      end

      def call
        if section_identifier == :candidate_headline_statistics
          generate(headings: candidate_headline_statistics_headings, rows: [candidate_headline_unique_row])
        else
          generate(headings:, rows:)
        end
      end

      def headings
        I18n.t('publications.itt_monthly_report_generator.status').each_key.map do |status|
          status_title = I18n.t("publications.itt_monthly_report_generator.status.#{status}.title")
          ["#{status_title} this cycle", "#{status_title} last cycle"]
        end.flatten.unshift(section[:subtitle])
      end

      def rows
        grouped_row.map do |key, value|
          [
            key,
            I18n.t('publications.itt_monthly_report_generator.status').each_key.map do |status|
              [value[status][:this_cycle], value[status][:last_cycle]]
            end,
          ].flatten
        end
      end

    private

      def generate(headings:, rows:)
        data = SafeCSV.generate(rows, headings)
        size = data.size

        {
          size:,
          data:,
        }
      end

      def grouped_row(grouped_data = {})
        section_data.each.map do |status, records|
          records.each.map do |record|
            title = record[:title]

            grouped_data[title] ||= { status => record }
            grouped_data[title][status] = record
          end
        end

        grouped_data
      end

      def candidate_headline_statistics_headings
        section_data.each_value.map do |value|
          ["#{value[:title]} this cycle", "#{value[:title]} last cycle"]
        end.flatten
      end

      def candidate_headline_unique_row
        section_data.each_value.map { |value| [value[:this_cycle], value[:last_cycle]] }.flatten
      end
    end
  end
end
