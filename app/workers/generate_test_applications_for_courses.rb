class GenerateTestApplicationsForCourses
  include Sidekiq::Worker

  def perform(course_ids, courses_per_application, previous_cycle, incomplete_references = false)
    generate_single(course_ids, courses_per_application, previous_cycle, incomplete_references)
  end

private

  def generate_single(course_ids, courses_per_application, previous_cycle, incomplete_references)
    courses_to_apply_to = Course.where(id: course_ids, recruitment_cycle_year: TestProvider.recruitment_cycle_year(previous_cycle))

    TestApplications.new.create_application(
      recruitment_cycle_year: TestProvider.recruitment_cycle_year(previous_cycle),
      states: application_state(previous_cycle, courses_per_application),
      courses_to_apply_to:,
      incomplete_references:,
    )
  end

  def application_state(previous_cycle, courses_per_application)
    if previous_cycle
      states_for_previous_cycle(courses_per_application)
    else
      [:awaiting_provider_decision] * courses_per_application
    end
  end

  def states_for_previous_cycle(courses_per_application)
    states = ([:awaiting_provider_decision] * (courses_per_application - 1)) << :pending_conditions
    states.shuffle
  end
end
