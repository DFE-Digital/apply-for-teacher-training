module SupportInterface
  class ValidationErrorsSummaryComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :validation_error_summary, :scoped_error_object, :source_name, :error_source, :select_sort_options

    def initialize(validation_error_summary:, scoped_error_object:, source_name:, error_source:, select_sort_options:)
      @validation_error_summary = validation_error_summary
      @scoped_error_object = scoped_error_object
      @source_name = source_name
      @error_source = error_source
      @select_sort_options = select_sort_options
    end

    def format_value(object)
      return object if source_name == :vendor_api

      object.demodulize.underscore.humanize
    end
  end
end
