module Publications
  module MonthlyStatistics
    class CSVSection
      attr_reader :section_identifier, :records, :title_section, :grouped_data

      def initialize(section_identifier:, records:, title_section:, grouped_data:)
        @section_identifier = section_identifier
        @records = Array(records)
        @title_section = title_section
        @grouped_data = grouped_data
      end

      def call
        data = SafeCSV.generate(rows, headings)
        size = data.size

        {
          size:,
          data:,
        }
      end

      def headings
        [
          main_attribute_header,
          extra_attributes_headers,
          status_attributes_headers,
        ].flatten
      end

      def rows
        records.map do |record|
          [
            main_attribute(record),
            extra_attributes(record),
            status_attributes(record),
          ].flatten
        end
      end

    private

      def main_attribute_header
        return [] if title_column.blank?

        I18n.t("publications.itt_monthly_report_generator.#{section_identifier}.subtitle")
      end

      def extra_attributes_headers
        return [] if extra_columns.blank?

        extra_columns.each_key.map do |column_name|
          I18n.t("publications.itt_monthly_report_generator.#{section_identifier}.#{column_name}")
        end
      end

      def status_attributes_headers
        statuses = grouped_data.keys.reject do |status|
          StatisticsDataProcessor.new(status_data: grouped_data[status]).violates_gdpr?
        end

        statuses.map do |status|
          status_title = I18n.t("publications.itt_monthly_report_generator.status.#{status}.title")

          ["#{status_title} this cycle", "#{status_title} last cycle"]
        end
      end

      def main_attribute(record)
        return [] if title_column.blank?

        record.send(title_column)
      end

      def extra_attributes(record)
        return [] if extra_columns.blank?

        extra_columns.values.map do |bigquery|
          record.send(bigquery[:attribute])
        end
      end

      def status_attributes(record)
        grouped_data.each_key.map do |status|
          [
            column_value_for(record:, status:, cycle: :this_cycle),
            column_value_for(record:, status:, cycle: :last_cycle),
          ]
        end
      end

      def title_column
        return if title_section.blank?
        return title_section unless title_section.respond_to?(:each_pair)

        title_section[:title_column]
      end

      def extra_columns
        return unless title_section.respond_to?(:each_pair)

        title_section[:extra_columns]
      end

      def column_value_for(record:, status:, cycle:)
        record.send(
          I18n.t("publications.itt_monthly_report_generator.status.#{status}.application_metrics_column.#{cycle}"),
        )
      end
    end
  end
end
