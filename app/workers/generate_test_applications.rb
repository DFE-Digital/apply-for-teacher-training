class GenerateTestApplications
  include Sidekiq::Worker

  def perform(next_cycle_applications = false)
    raise 'You cannot generate test data in production' if HostingEnvironment.production?

    current_cycle_courses = courses_from_cycle(current_year)
    current_cycle_undergraduate_courses = undergraduate_courses_from_cycle(current_year)
    previous_cycle_courses = courses_from_cycle(previous_year)
    next_cycle_courses = courses_from_cycle(next_year)

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

      next_cycle_states += continuous_application_choices_states

      next_cycle_states.each do |states|
        create(
          recruitment_cycle_year: next_year,
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
          recruitment_cycle_year: previous_year,
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

      current_cycle_states += continuous_application_choices_states

      current_cycle_states.each do |states|
        create(
          recruitment_cycle_year: current_year,
          courses_to_apply_to: current_cycle_courses,
          states:,
        )

        create(
          recruitment_cycle_year: current_year,
          courses_to_apply_to: current_cycle_undergraduate_courses,
          states:,
        )
      end

      create(recruitment_cycle_year: current_year, states: %i[unsubmitted], course_full: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_year, states: %i[awaiting_provider_decision], courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_year, states: %i[awaiting_provider_decision], carry_over: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_year, states: %i[offer rejected], carry_over: true, courses_to_apply_to: current_cycle_courses)
      create(recruitment_cycle_year: current_year, states: %i[offer], courses_to_apply_to: current_cycle_courses)
    end

    StateChangeNotifier.disable_notifications do
      ProcessStaleApplications.new.call
    end
  end

private

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end

  def previous_year
    @previous_year ||= RecruitmentCycleTimetable.previous_year
  end

  def next_year
    @next_year ||= RecruitmentCycleTimetable.next_year
  end

  def create(
    recruitment_cycle_year:,
    states:,
    courses_to_apply_to:,
    carry_over: false,
    course_full: false
  )
    if course_full
      courses_to_apply_to = courses_to_apply_to.first(states.count)
      fill_vacancies(courses_to_apply_to)
    end

    ApplicationForm.with_unsafe_application_choice_touches do
      factory.create_application(
        carry_over:,
        states:,
        recruitment_cycle_year:,
        courses_to_apply_to:,
        course_full:,
      )
    end
  end

  def fill_vacancies(courses)
    courses.each do |course|
      course.course_options.update_all(vacancy_status: :no_vacancies) unless course.full?
    end
  end

  def factory
    TestApplications.new
  end

  def courses_from_cycle(year)
    courses = Course.with_course_options.in_cycle([current_year, year].min)

    if dev_support_user
      courses = courses.where(provider: dev_support_user.providers)
    end

    courses.distinct
  end

  def undergraduate_courses_from_cycle(year)
    recruitment_cycle_year = [current_year, year].min
    courses = Course
      .teacher_degree_apprenticeship
      .with_course_options
      .in_cycle(recruitment_cycle_year)

    if courses.none?
      common_used_provider_code = '1TZ'
      provider = Provider.find_by(code: common_used_provider_code) ||
                 Provider.all.sample(10).sample ||
                 FactoryBot.create(:provider)

      FactoryBot.create_list(
        :course,
        10,
        :teacher_degree_apprenticeship,
        :with_course_options,
        :open,
        recruitment_cycle_year:,
        provider:,
      )
    end

    courses.distinct
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
    if instance_variable_defined?(:@dev_support_user)
      @dev_support_user
    else
      @dev_support_user = ProviderUser.find_by(dfe_sign_in_uid: 'dev-support')
    end
  end
end
