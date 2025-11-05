class UnsubmittedApplicationChoicesForCourse
  attr_reader :course_id

  def initialize(course_id)
    @course_id = course_id
  end

  def self.call(course_id)
    new(course_id).call
  end

  def call
    ApplicationChoice
      .joins(:application_form)
      .joins(:candidate).merge(Candidate.for_marketing_or_nudge_emails)
      .joins(:current_course)
      .where(courses: { id: course_id })
      .where(
        status: 'unsubmitted',
        current_recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
      )
      .distinct
  end
end
