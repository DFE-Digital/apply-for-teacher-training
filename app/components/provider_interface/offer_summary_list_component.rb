module ProviderInterface
  class OfferSummaryListComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :application_choice, :header, :options

    def initialize(application_choice:, header: 'Your offer', options: {})
      @application_choice = application_choice
      @course_option = application_choice.offered_option
      @header = header
      @change_provider_path = options[:change_provider_path]
      @change_course_path = options[:change_course_path]
      @change_course_option_path = options[:change_course_option_path]
    end

    def rows
      [
        {
          key: 'Candidate name',
          value: application_choice.application_form.full_name,
        },
        {
          key: 'Provider',
          value: @course_option.course.provider.name,
          change_path: @change_provider_path, action: 'training provider'
        },
        {
          key: 'Course',
          value: @course_option.course.name_and_code,
          change_path: @change_course_path, action: 'course'
        },
        {
          key: 'Location',
          value: @course_option.site.name_and_address,
          change_path: @change_course_option_path, action: 'location'
        },
      ]
    end
  end
end
