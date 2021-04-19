module ProviderInterface
  class DeferredOfferDetailsComponent < ViewComponent::Base
    include ViewHelper
    include StatusBoxComponents::CourseRows

    attr_reader :application_choice

    def initialize(application_choice:, course_option: nil)
      @application_choice = application_choice
      @course_option = course_option
    end

    def rows
      [
        {
          key: 'Provider',
          value: course_option.provider.name,
        },
        {
          key: 'Course',
          value: course_option.course.name_and_code,
        },
        {
          key: 'Full time or part time',
          value: course_option.study_mode.humanize,
        },
        {
          key: 'Location',
          value: course_option.site.name_and_address,
        },
      ]
    end

  private

    def course_option
      @course_option || @application_choice.offered_option
    end
  end
end
