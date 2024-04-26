module ProviderInterface
  module RecruitmentPerformanceReport
    class SubmittedApplicationsTableComponent < ViewComponent::Base
      BIG_QUERY_COLUMN_NAMES_MAPPING = { this_cycle: 'number_of_candidates_submitted_to_date',
                                         last_cycle: 'number_of_candidates_submitted_to_same_date_previous_cycle',
                                         percentage_change: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle' }.freeze

      def initialize(provider, provider_statistics, national_statistics)
        @provider = provider
        @row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
          field_mapping: BIG_QUERY_COLUMN_NAMES_MAPPING,
          provider_statistics:,
          national_statistics:,
        )
      end

      def call
        render SubjectTableComponent.new(
          @provider,
          table_caption: t('subject_table_component.caption_submitted_applications_table'),
          subject_rows: @row_builder.subject_rows,
          summary_row: @row_builder.summary_row,
        )
      end
    end
  end
end
