module SupportInterface
  class CourseChoicesTableComponent < ViewComponent::Base
    include ViewHelper

    def initialize(course_options:)
      @course_options = course_options
    end

    def course_rows
      @course_options.sort_by { |course_option| course_option.course.name }
    end
  end
end
