class GenerateTestApplicationsForCourses
  include Sidekiq::Worker

  def perform(course_ids, courses_per_application, count = nil)
    if count.present?
      generate_multiple(course_ids, courses_per_application, count)
    else
      generate_single(course_ids, courses_per_application)
    end
  end

private

  def generate_single(course_ids, courses_per_application)
    courses_to_apply_to = Course.where(id: course_ids)

    TestApplications.new.create_application(
      recruitment_cycle_year: RecruitmentCycle.current_year,
      states: [:awaiting_provider_decision] * courses_per_application,
      courses_to_apply_to: courses_to_apply_to,
    )
  end

  # Included for backwards compatibility, since at deployment time old jobs with outdated parameters may not have been picked up yet.
  def generate_multiple(course_ids, courses_per_application, count)
    courses_to_apply_to = Course.where(id: course_ids)

    1.upto(count).flat_map do
      TestApplications.new.create_application(
        recruitment_cycle_year: RecruitmentCycle.current_year,
        states: [:awaiting_provider_decision] * courses_per_application,
        courses_to_apply_to: courses_to_apply_to,
      )
    end
  end
end
