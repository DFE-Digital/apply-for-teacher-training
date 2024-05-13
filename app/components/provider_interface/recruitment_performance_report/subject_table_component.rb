module ProviderInterface
  module RecruitmentPerformanceReport
    class SubjectTableComponent < ViewComponent::Base
      attr_reader :provider, :table_caption, :summary_row, :subject_rows
      def initialize(provider, table_caption:, summary_row:, subject_rows:)
        @provider = provider
        @table_caption = table_caption
        @summary_row = summary_row
        @subject_rows = subject_rows
      end

      def format_number(row, column_name)
        number = row.send(column_name)

        # We want nil to read 'Not available'
        return t('shared.not_available') if number.nil?

        if column_name.in?(%i[percentage_change national_percentage_change])
          number_to_percentage((number - 1) * 100, precision: 0)
        else
          number_with_delimiter(number)
        end
      end

      def provider_name
        @provider.name
      end

      def columns
        %i[last_cycle this_cycle percentage_change national_last_cycle national_this_cycle national_percentage_change]
      end

      def colspan
        columns.length / 2
      end

      def subheading_html_attributes(column_name = '')
        html_class = ['recruitment-performance-report-table-subheading']

        if column_name.in?(%i[last_cycle national_last_cycle])
          html_class << 'recruitment-performance-report-table-subheading__border-left'
        end

        { html_attributes: { class: html_class } }
      end

      def numeric_html_attributes(column_name)
        return {} unless column_name.in?(%i[last_cycle national_last_cycle])

        { html_attributes: { class: 'recruitment-performance-report-table-subject-rows__border-left' } }
      end

      def level_html_attributes(subject_row)
        return {} if subject_row.level == 'Level'

        html_class = 'recruitment-performance-report-table-subject-rows__secondary-subject-row-heading'

        { html_attributes: { class: html_class } }
      end

      def summary_heading_html_attributes
        %w[govuk-table__cell recruitment-performance-report-table-summary-row]
      end

      def summary_row_html_attributes(column_name)
        html_class = %w[govuk-table__cell govuk-table__cell--numeric recruitment-performance-report-table-summary-row]
        if column_name.in?(%i[last_cycle national_last_cycle])
          html_class << 'recruitment-performance-report-table-summary-row__border-left'
        end
        { html_attributes: { class: html_class } }
      end
    end
  end
end
