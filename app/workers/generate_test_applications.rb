class GenerateTestApplications
  include Sidekiq::Worker

  def perform
    raise 'You cannot generate test data in production' if HostingEnvironment.production?

    current_cycle = RecruitmentCycle.current_year
    previous_cycle = RecruitmentCycle.previous_year

    create recruitment_cycle_year: previous_cycle, states: %i[rejected rejected]
    create recruitment_cycle_year: previous_cycle, states: %i[offer_withdrawn]
    create recruitment_cycle_year: previous_cycle, states: %i[offer_deferred]
    create recruitment_cycle_year: previous_cycle, states: %i[offer_deferred]
    create recruitment_cycle_year: previous_cycle, states: %i[declined]
    create recruitment_cycle_year: previous_cycle, states: %i[accepted]
    create recruitment_cycle_year: previous_cycle, states: %i[recruited]
    create recruitment_cycle_year: previous_cycle, states: %i[conditions_not_met]
    create recruitment_cycle_year: previous_cycle, states: %i[withdrawn]
    create recruitment_cycle_year: previous_cycle, states: %i[application_not_sent]

    create recruitment_cycle_year: current_cycle, states: %i[unsubmitted]
    create recruitment_cycle_year: current_cycle, states: %i[unsubmitted], course_full: true
    create recruitment_cycle_year: current_cycle, states: %i[unsubmitted_with_completed_references]
    create recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision awaiting_provider_decision awaiting_provider_decision]
    create recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision awaiting_provider_decision awaiting_provider_decision]
    create recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision awaiting_provider_decision awaiting_provider_decision]
    create recruitment_cycle_year: current_cycle, states: %i[interviewing awaiting_provider_decision offer]
    create recruitment_cycle_year: current_cycle, states: %i[interviewing interviewing]
    create recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision], apply_again: true
    create recruitment_cycle_year: current_cycle, states: %i[awaiting_provider_decision], carry_over: true
    create recruitment_cycle_year: current_cycle, states: %i[offer offer]
    create recruitment_cycle_year: current_cycle, states: %i[offer_changed]
    create recruitment_cycle_year: current_cycle, states: %i[offer rejected]
    create recruitment_cycle_year: current_cycle, states: %i[offer rejected], carry_over: true
    create recruitment_cycle_year: current_cycle, states: %i[offer], apply_again: true
    create recruitment_cycle_year: current_cycle, states: %i[rejected rejected]
    create recruitment_cycle_year: current_cycle, states: %i[offer_withdrawn]
    create recruitment_cycle_year: current_cycle, states: %i[offer_deferred]
    create recruitment_cycle_year: current_cycle, states: %i[offer_deferred]
    create recruitment_cycle_year: current_cycle, states: %i[declined]
    create recruitment_cycle_year: current_cycle, states: %i[accepted]
    create recruitment_cycle_year: current_cycle, states: %i[accepted_no_conditions]
    create recruitment_cycle_year: current_cycle, states: %i[recruited]
    create recruitment_cycle_year: current_cycle, states: %i[conditions_not_met]
    create recruitment_cycle_year: current_cycle, states: %i[withdrawn]

    StateChangeNotifier.disable_notifications do
      RejectApplicationsByDefault.new.call
    end
  end

private

  def create(recruitment_cycle_year:, states:, apply_again: false, carry_over: false, course_full: false)
    TestApplications.new.create_application(
      states: states,
      recruitment_cycle_year: recruitment_cycle_year,
      courses_to_apply_to: courses_to_apply_to(recruitment_cycle_year),
      apply_again: apply_again,
      carry_over: carry_over,
      course_full: course_full,
    )
  end

  def courses_to_apply_to(year)
    courses = Course.open_on_apply.in_cycle(year)

    if dev_support_user
      courses = courses.where(provider: dev_support_user.providers)
    end

    courses
  end

  def dev_support_user
    @dev_support_user ||= ProviderUser.find_by(dfe_sign_in_uid: 'dev-support')
  end
end
