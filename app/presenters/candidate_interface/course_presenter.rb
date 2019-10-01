module CandidateInterface
  class CoursePresenter
    def initialize(course = nil)
      @course = course
    end

    def provider_code
      @course.provider_code
    end

    def course_code
      @course.course_code
    end

    def name
      @course.name
    end

    def name_and_code
      "#{name} (#{course_code})"
    end
  end
end
