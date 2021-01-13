module SupportInterface
  class CourseNameAndStatusComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :course_option

    def initialize(course_option:)
      @course_option = course_option
    end
  end
end
