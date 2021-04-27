module SupportInterface
  class ValidationErrorsComponentPreview < ViewComponent::Preview
    include SelectOptionsHelper
    def validation_error_list
      distinct_errors_with_counts = ValidationError.list_of_distinct_errors_with_count
      grouped_counts = ValidationError.group(:form_object).count

      render SupportInterface::ValidationErrorsListComponent.new(
        distinct_errors_with_counts: distinct_errors_with_counts,
        grouped_counts: grouped_counts,
        scoped_error_object: :form_object,
        source_name: :candidate,
        grouped_counts_label: 'Form',
      )
    end

    def validation_error_summary
      validation_error_summary = ::ValidationErrorSummaryQuery.new('all_time').call

      render SupportInterface::ValidationErrorsSummaryComponent.new(
        validation_error_summary: validation_error_summary,
        scoped_error_object: :form_object,
        source_name: :candidate,
        error_source: :users,
        select_sort_options: select_sort_options,
      )
    end
  end
end
