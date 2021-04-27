module SupportInterface
  class ValidationErrorsComponentPreview < ViewComponent::Preview
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
  end
end
