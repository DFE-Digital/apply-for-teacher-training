module SupportInterface
  class CourseNameAndStatusComponent < BaseComponent
    include ViewHelper

    attr_reader :course_option

    def initialize(course_option:)
      @course_option = course_option
    end
  end
end
