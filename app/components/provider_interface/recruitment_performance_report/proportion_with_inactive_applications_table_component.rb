module ProviderInterface
  module RecruitmentPerformanceReport
    class ProportionWithInactiveApplicationsTableComponent < ViewComponent::Base
      BIG_QUERY_COLUMN_NAMES_MAPPING = {
        this_cycle: 'number_of_candidates_who_had_an_inactive_application_this_cycle_to_date_as_proportion_of_submitted_candidates',
      }.freeze

      def initialize(provider, provider_statistics, national_statistics)
        @provider = provider
        @row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
          field_mapping: BIG_QUERY_COLUMN_NAMES_MAPPING,
          provider_statistics:,
          national_statistics:,
        )
      end

      def subject_rows
        @subject_rows ||= @row_builder.subject_rows
      end

      def summary_row
        @summary_row ||= @row_builder.summary_row
      end

      def format_number(row, column_name)
        number = row.send(column_name)
        # The field may be 'Not available'
        return t('shared.not_available') if number.nil?

        number_to_percentage(number * 100, precision: 0)
      end

      def provider_name
        @provider.name
      end

      def columns
        %i[this_cycle national_this_cycle]
      end

      def level_html_attributes(subject_row)
        return {} if subject_row.level == 'Level'

        html_class = 'recruitment-performance-report-table__cell--secondary-subject'

        { html_attributes: { class: html_class } }
      end

      def summary_heading_html_attributes
        %w[govuk-table__cell recruitment-performance-report-table__cell--summary]
      end

      def summary_row_html_attributes(_column_name)
        html_class = %w[govuk-table__cell
                        govuk-table__cell--numeric
                        recruitment-performance-report-table__cell--summary]

        { html_attributes: { class: html_class } }
      end
    end
  end
end
