class GenerateTestApplications
  include Sidekiq::Worker

  def perform(next_cycle_applications = false)
    raise 'You cannot generate test data in production' if HostingEnvironment.production?

    current_cycle = RecruitmentCycle.current_year
    current_cycle_courses = courses_from_cycle(current_cycle)
    previous_cycle = RecruitmentCycle.previous_year
    previous_cycle_courses = courses_from_cycle(previous_cycle)
    next_cycle = RecruitmentCycle.next_year
    next_cycle_courses = courses_from_cycle(next_cycle)

    if next_cycle_applications
      next_cycle_states = [
        %i[unsubmitted],
        %i[unsubmitted_with_completed_references],
        %i[awaiting_provider_decision],
        %i[awaiting_provider_decision],
        %i[offer awaiting_provider_decision offer],
        %i[offer],
        %i[offer],
        %i[offer_withdrawn],
        %i[offer_deferred],
        %i[pending_conditions],
        %i[pending_conditions],
        %i[recruited],
        %i[rejected rejected],
      ]

      next_cycle_states += continuous_application_choices_states if FeatureFlag.active?(:continuous_applications)

      next_cycle_states.each do |states|
        create(
          recruitment_cycle_year: next_cycle,
          courses_to_apply_to: next_cycle_courses,
          states:,
        )
      end

    else
      [
        %i[rejected rejected],
        %i[offer_withdrawn],
        %i[offer_deferred],
        %i[offer_deferred],
        %i[declined],
        %i[accepted],
        %i[recruited],
        %i[conditions_not_met],
        %i[withdrawn],
        %i[application_not_sent],
      ].each do |states|
        create(
          recruitment_cycle_year: previous_cycle,
          courses_to_apply_to: previous_cycle_courses,
          states:,
        )
      end

      current_cycle_states = [
        %i[unsubmitted],
        %i[unsubmitted_with_completed_references],
        %i[awaiting_provider_decision awaiting_provider_decision awaiting_provider_decision],
        %i[awaiting_provider_decision awaiting_provider_decision awaiting_provider_decision],
        %i[awaiting_provider_decision awaiting_provider_decision awaiting_provider_decision],
        %i[interviewing awaiting_provider_decision offer],
        %i[interviewing interviewing],
        %i[offer offer],
        %i[course_changed_after_offer],
        %i[offer rejected],
        %i[rejected rejected],
        %i[offer_withdrawn],
        %i[offer_deferred],
        %i[offer_deferred],
        %i[declined],
        %i[accepted],
        %i[accepted_no_conditions],
        %i[recruited],
        %i[conditions_not_met],
        %i[withdrawn],
      ]

      if FeatureFlag.active?(:continuous_applications) && current_cycle > 2023
        current_cycle_states += continuous_application_choices_states
      end

      current_cycle_states.each do |states|
        create(
          recruitment_cycle_year: current_cycle,
          courses_to_apply_to: current_cycle_courses,
          states:,
        )
      end

      create(recruitment_cycle_year: current_cycle, states: %i[unsubmitted], course_full: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision], apply_again: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision], carry_over: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_cycle, states: %i[offer rejected], carry_over: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_cycle, states: %i[offer], apply_again: true, courses_to_apply_to: current_cycle_courses)
    end

    StateChangeNotifier.disable_notifications do
      ProcessStaleApplications.new.call
    end
  end

private

  def create(
    recruitment_cycle_year:,
    states:,
    courses_to_apply_to:,
    apply_again: false,
    carry_over: false,
    course_full: false
  )
    if course_full
      courses_to_apply_to = courses_to_apply_to.first(states.count)
      fill_vacancies(courses_to_apply_to)
    end

    factory.create_application(
      apply_again:,
      carry_over:,
      states:,
      recruitment_cycle_year:,
      courses_to_apply_to:,
      course_full:,
    )
  end

  def fill_vacancies(courses)
    courses.each do |course|
      course.course_options.update_all(vacancy_status: :no_vacancies) unless course.full?
    end
  end

  def factory
    if FeatureFlag.active?(:sample_applications_factory)
      SampleApplicationsFactory
    else
      TestApplications.new
    end
  end

  def courses_from_cycle(year)
    courses = Course.open_on_apply.in_cycle([RecruitmentCycle.current_year, year].min)

    if dev_support_user
      courses = courses.where(provider: dev_support_user.providers)
    end

    courses
  end

  def continuous_application_choices_states
    [
      %i[inactive],
      %i[inactive],
      %i[unsubmitted awaiting_provider_decision awaiting_provider_decision rejected offer],
      %i[unsubmitted awaiting_provider_decision awaiting_provider_decision rejected offer],
      %i[unsubmitted awaiting_provider_decision interviewing offer],
      %i[unsubmitted awaiting_provider_decision interviewing offer],
      %i[inactive unsubmitted awaiting_provider_decision withdrawn],
      %i[inactive unsubmitted awaiting_provider_decision withdrawn],
      %i[unsubmitted unsubmitted unsubmitted unsubmitted],
      %i[unsubmitted unsubmitted unsubmitted unsubmitted],
    ]
  end

  def dev_support_user
    @dev_support_user ||= ProviderUser.find_by(dfe_sign_in_uid: 'dev-support')
  end
end
