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
        status_headings = I18n.t('publications.itt_monthly_report_generator.status').each_key.map do |status|
          status_title = I18n.t("publications.itt_monthly_report_generator.status.#{status}.title")
          ["#{status_title} this cycle", "#{status_title} last cycle"]
        end

        [section[:subtitle], extra_headings, status_headings].flatten.compact
      end

      def rows
        grouped_row.map do |key, value|
          [
            title_for(key),
            extra_attributes(value),
            I18n.t('publications.itt_monthly_report_generator.status').each_key.map do |status|
              [value[status][:this_cycle], value[status][:last_cycle]].compact
            end,
          ].compact.flatten
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
            grouped_key = if sections_with_extra_columns?
                            "#{record[:title]},#{record[:subject]}"
                          else
                            record[:title]
                          end

            grouped_data[grouped_key] ||= { status => record }
            grouped_data[grouped_key][status] = record
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

      def extra_headings
        I18n.t("publications.itt_monthly_report_generator.#{section_identifier}.subject") if sections_with_extra_columns?
      end

      def extra_attributes(statuses)
        if sections_with_extra_columns?
          statuses.each_value.map { |status| status[:subject] }.uniq
        end
      end

      def sections_with_extra_columns?
        section_identifier.in?(sections_with_extra_columns)
      end

      def sections_with_extra_columns
        %i[candidate_provider_region_and_subject candidate_area_and_subject]
      end

      def title_for(key)
        return key unless sections_with_extra_columns?

        key.split(',').first
      end
    end
  end
end
