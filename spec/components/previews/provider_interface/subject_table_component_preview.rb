module ProviderInterface
  class SubjectTableComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    FIELD_MAPPING_WITH_CHANGE = {
      this_cycle: 'number_of_candidates_submitted_to_date',
      last_cycle: 'number_of_candidates_submitted_to_same_date_previous_cycle',
      percentage_change: 'number_of_candidates_submitted_to_date_as_proportion_of_last_cycle',
    }.freeze

    FIELD_MAPPING_WITHOUT_CHANGE = {
      this_cycle: 'offer_rate_to_date',
      last_cycle: 'offer_rate_to_same_date_previous_cycle',
    }.freeze

    def with_percentage_change_data
      row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
        field_mapping: FIELD_MAPPING_WITH_CHANGE,
        provider_statistics: provider_report.statistics,
        national_statistics: national_report.statistics,
      )

      render ProviderInterface::RecruitmentPerformanceReport::SubjectTableComponent.new(
        provider_report.provider,
        table_caption: 'Table including percentage change data',
        summary_row: row_builder.summary_row,
        subject_rows: row_builder.subject_rows,
      )
    end

    def without_percentage_change_data
      row_builder = ProviderInterface::Reports::SubjectRowsBuilderService.new(
        field_mapping: FIELD_MAPPING_WITHOUT_CHANGE,
        provider_statistics: provider_report.statistics,
        national_statistics: national_report.statistics,
      )

      render ProviderInterface::RecruitmentPerformanceReport::SubjectTableComponent.new(
        provider_report.provider,
        table_caption: 'Table without percentage change data',
        summary_row: row_builder.summary_row,
        subject_rows: row_builder.subject_rows,
      )
    end

  private

    def national_report
      @national_report ||=
        Publications::NationalRecruitmentPerformanceReport.last ||
        FactoryBot.create(:national_recruitment_performance_report)
    end

    def provider_report
      @provider_report ||=
        Publications::ProviderRecruitmentPerformanceReport.last ||
        FactoryBot.create(:provider_recruitment_performance_report)
    end
  end
end
