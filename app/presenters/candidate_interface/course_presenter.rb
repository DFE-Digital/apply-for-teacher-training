module CandidateInterface
  class CoursePresenter
    def initialize(course = nil)
      @course = course
    end

    def provider_code
      @course.provider.code
    end

    def course_code
      @course.code
    end

    def name
      @course.name
    end

    def name_and_code
      "#{name} (#{course_code})"
    end
  end
end
