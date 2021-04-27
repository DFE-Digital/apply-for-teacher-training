module SupportInterface
  class ValidationErrorsListComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :distinct_errors_with_counts, :grouped_counts, :scoped_error_object, :source_name, :grouped_counts_label

    def initialize(distinct_errors_with_counts:, grouped_counts:, scoped_error_object:, source_name:, grouped_counts_label:)
      @distinct_errors_with_counts = distinct_errors_with_counts
      @grouped_counts = grouped_counts
      @scoped_error_object = scoped_error_object
      @source_name = source_name
      @grouped_counts_label = grouped_counts_label
    end

    def format_value(object)
      return object if source_name == :vendor_api

      object.demodulize.underscore.humanize
    end
  end
end
