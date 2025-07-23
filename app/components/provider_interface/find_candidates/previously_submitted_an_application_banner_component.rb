class ProviderInterface::FindCandidates::PreviouslySubmittedAnApplicationBannerComponent < ViewComponent::Base
  def initialize(application_form:, current_provider_user:)
    @application_form = application_form
    @current_provider_user = current_provider_user
  end

  def render?
    associated_application_choices_this_cycle.any? || associated_application_choices_in_a_previous_cycle.any?
  end

  def rows
    rows_by_year = {}

    # Current cycle rows
    rows_by_year[current_year] = associated_application_choices_this_cycle.map { |choice| build_row(choice) }

    # Previous cycle rows
    associated_application_choices_previous_cycles_by_year.each do |year, choices|
      rows_by_year[year] ||= []
      rows_by_year[year].concat(choices.map { |choice| build_row(choice) })
    end

    # Order by year descending
    rows_by_year.sort_by { |year, _| year }.reverse.to_h
  end

private

  def build_row(choice)
    {
      text: govuk_link_to(
        t(
          'provider_interface.find_candidates.previously_submitted_an_application_banner_component.text',
          course: choice.course.name_and_code,
          provider: choice.provider.name,
        ),
        provider_interface_application_choice_path(choice),
      ),
      application_choice: choice,
    }
  end

  def associated_application_choices_this_cycle
    @associated_application_choices_this_cycle ||=
      @application_form
      .application_choices
      .visible_to_provider
      .joins(course: :provider)
      .where(courses: { provider_id: @current_provider_user.providers.pluck(:id) })
      .includes(:published_withdrawal_reasons, :course_option, :course, :provider)
  end

  def associated_application_choices_in_a_previous_cycle
    @associated_application_choices_in_a_previous_cycle ||=
      ApplicationChoice
        .visible_to_provider
        .joins(:application_form, course: :provider)
        .where(application_forms: { candidate_id: candidate.id })
        .where(courses: { provider_id: @current_provider_user.providers.pluck(:id) })
        .where.not(application_forms: { recruitment_cycle_year: current_year })
  end

  def associated_application_choices_previous_cycles_by_year
    associated_application_choices_in_a_previous_cycle.group_by do |choice|
      choice.application_form.recruitment_cycle_year
    end
  end

  def current_year
    @current_year ||= RecruitmentCycleTimetable.current_year
  end

  def candidate
    @application_form.candidate
  end
end
