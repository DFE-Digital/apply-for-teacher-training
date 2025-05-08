class GenerateTestApplicationsForCourses
  include Sidekiq::Worker

  def perform(course_ids, courses_per_application, previous_cycle, incomplete_references = false, next_cycle = false)
    generate_single(course_ids, courses_per_application, previous_cycle, incomplete_references, next_cycle)
  end

private

  def generate_single(course_ids, courses_per_application, previous_cycle, incomplete_references, next_cycle)
    # For applications in the next cycle use courses from the previous cycle
    courses_to_apply_to = Course.where(id: course_ids, recruitment_cycle_year: TestProvider.recruitment_cycle_year(previous_cycle))

    recruitment_cycle_year = if next_cycle
                               next_year
                             else
                               TestProvider.recruitment_cycle_year(previous_cycle)
                             end

    factory.create_application(
      recruitment_cycle_year: recruitment_cycle_year,
      states: application_state(previous_cycle, courses_per_application, next_cycle),
      courses_to_apply_to:,
      incomplete_references:,
    )
  end

  def factory
    TestApplications.new
  end

  def application_state(previous_cycle, courses_per_application, next_cycle)
    [
      :declined,
      :rejected,
      :withdrawn,
      :declined,
      :rejected,
      :withdrawn,
      :declined,
      :rejected,
      :withdrawn,
      :pending_conditions, # won't be in the pool
      :awaiting_provider_decision, # won't be in the pool
    ].shuffle
     .sample(courses_per_application) # for the Bug Party this value is only ever 1, 2 or 3
  end

  def states_for_next_cycle
    %i[pending_conditions awaiting_provider_decision]
  end

  def states_for_previous_cycle(courses_per_application)
    states = ([:awaiting_provider_decision] * (courses_per_application - 1)) << :pending_conditions
    states.shuffle
  end

  def next_year
    @next_year ||= RecruitmentCycleTimetable.next_year
  end
end
