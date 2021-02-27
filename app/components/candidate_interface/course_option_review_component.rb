module CandidateInterface
  class CourseOptionReviewComponent < ViewComponent::Base
    include ViewHelper

    def initialize(course_option:)
      @course_option = course_option
    end

    def course_option_rows
      [
        course_row,
        location_row,
        study_mode_row,
      ]
    end

  private

    def course_row
      {
        key: 'Course',
        value: "#{@course_option.course.name} <br> #{@course_option.course.description}".html_safe,
      }
    end

    def location_row
      {
        key: 'Location',
        value: @course_option.site.name_and_address,
      }
    end

    def study_mode_row
      {
        key: 'Study mode',
        value: @course_option.study_mode.humanize,
      }
    end
  end
end
