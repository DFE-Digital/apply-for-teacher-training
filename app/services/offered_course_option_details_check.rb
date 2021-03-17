class OfferedCourseOptionDetailsCheck
  class InvalidStateError < StandardError
    attr_accessor :detail

    def initialize(detail)
      @detail = detail.to_s.humanize(capitalize: false)
    end

    def message
      "Invalid #{detail} for CourseOption"
    end
  end

  attr_reader :provider_id, :course_id, :course_option_id, :study_mode, :recruitment_cycle_year

  def initialize(
    provider_id:,
    course_id:,
    course_option_id:,
    study_mode:
  )
    @provider_id = provider_id
    @course_id = course_id
    @course_option_id = course_option_id
    @study_mode = study_mode
  end

  def validate!
    course_option = CourseOption.find(course_option_id)

    raise InvalidStateError, :provider if course_option.course.provider_id != provider_id
    raise InvalidStateError, :course if course_option.course_id != course_id
    raise InvalidStateError, :study_mode if course_option.study_mode != study_mode
  end
end
