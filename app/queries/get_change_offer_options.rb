class GetChangeOfferOptions
  attr_accessor :application_choice, :user

  def initialize(application_choice:, user:)
    @application_choice = application_choice
    @user = user
  end

  def available_providers
    make_decision_providers = user.provider_permissions.where(make_decisions: true).map(&:provider)

# course -> provider            -> provider_relationship_permissions (training side) -> providers
#        -> accredited_provider -> provider_relationship_permissions (ratifying side) -> providers

    # provider_id IN (1, 2, 3, 5)

    # .with(
      # provider_ids: user.provider_permissions.where(make_decisions: true).pluck(:provider_id)
    # )
    # .with(
      # training_providers:
        # Provider.joins('INNER JOIN courses ON courses.provider_id = providers.id AND courses.provider_id IN provider_ids')
    # )

    # .with(ratifying_providers: Course.where(accredited_provider: make_decision_providers))

    courses = Course.where(open_on_apply: true,
                          provider: make_decision_providers,
                          recruitment_cycle_year: application_choice.offered_course.recruitment_cycle_year,
                           )
                          .or(
                              Course.where(open_on_apply: true,
                              accredited_provider: make_decision_providers,
                              recruitment_cycle_year: application_choice.offered_course.recruitment_cycle_year,)
                            )

    courses.map(&:provider)
  end

  # GetChangeOfferOptions.new(application_choice: ..., user: ...).available_courses(provider: ...)
  def available_courses(provider:)
  end

  # GetChangeOfferOptions.new(application_choice: ..., user: ...).available_study_modes(course: ...)
  def available_study_modes(course:)
  end
  
  # GetChangeOfferOptions.new(application_choice: ..., user: ...).available_sites(course: ..., study_mode: ...)

  #   @available_courses = Course.where(
  #     open_on_apply: true,
  #     provider: application_choice.offered_course.provider,
  #     study_mode: study_mode_for_other_courses,
  #     recruitment_cycle_year: application_choice.offered_course.recruitment_cycle_year,
  #   ).order(:name)
  #
  #   @available_study_modes = CourseOption.where(
  #     course: application_choice.offered_course,
  #   ).pluck(:study_mode).uniq
  #
  #   @available_course_options = CourseOption.where(
  #     course: application_choice.offered_course,
  #     study_mode: application_choice.offered_option.study_mode, # preserving study_mode
  #   ).includes(:site).order('sites.name')
  # end

private

end
