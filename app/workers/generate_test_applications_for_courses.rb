class GenerateTestApplicationsForCourses
  include Sidekiq::Worker

  def perform(course_ids, courses_per_application, count)
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
