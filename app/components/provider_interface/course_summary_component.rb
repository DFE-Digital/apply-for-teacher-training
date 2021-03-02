module ProviderInterface
  class CourseSummaryComponent < ViewComponent::Base
    attr_reader :course_option, :provider_name, :course_name_and_code,
                :location_name_and_address, :study_mode

    def initialize(course_option:)
      @course_option = course_option
      @provider_name = course_option.provider.name
      @course_name_and_code = course_option.course.name_and_code
      @location_name_and_address = course_option.site.name_and_address
      @study_mode = course_option.study_mode.humanize
    end

    def rows
      [
        {
          key: 'Provider',
          value: provider_name,
        },
        {
          key: 'Course',
          value: course_name_and_code,
        },
        {
          key: 'Location',
          value: location_name_and_address,
        },
        {
          key: 'Full time or part time',
          value: study_mode,
        },
      ]
    end
  end
end
