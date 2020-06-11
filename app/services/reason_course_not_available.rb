class ReasonCourseNotAvailable
  attr_accessor :application_choice

  def initialize(application_choice)
    self.application_choice = application_choice
  end

  def call
    return :course_withdrawn if application_choice.course_withdrawn?

    # all course options for the given course are full
    return :course_full if application_choice.course_full?

    # all course options for the given course are full at the selected location
    return :location_full if application_choice.site_full?

    # all part/full-time course options are full for the given course
    return :study_mode_full if application_choice.study_mode_full?

    raise ArgumentError, 'Course is available'
  end
end
