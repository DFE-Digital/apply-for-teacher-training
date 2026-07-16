class CandidateInterface::MultipleActiveApplicationsContentComponentPreview < ViewComponent::Preview
  def with_current_year_applications
    component = PreviewMultipleActiveApplicationsContentComponent.new(application_form:)
    component.application_choices
    render component
  end

  def with_no_current_year_applications
    component = PreviewMultipleActiveApplicationsContentComponent.new(application_form:, with_current_year_applications: false)
    component.application_choices
    render component
  end

  def after_winter_reject_by_default
    component = PreviewMultipleActiveApplicationsContentComponent.new(
      application_form:,
      with_current_year_applications: true,
      january_choice_state: :rejected_by_default,
    )
    component.application_choices
    render component
  end

  def after_winter_declined_by_default
    component = PreviewMultipleActiveApplicationsContentComponent.new(
      application_form:,
      with_current_year_applications: true,
      january_choice_state: :declined_by_default,
    )
    component.application_choices
    render component
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewMultipleActiveApplicationsContentComponent < CandidateInterface::MultipleActiveApplicationsContentComponent
    def initialize(application_form:, with_current_year_applications: true, january_choice_state: :awaiting_provider_decision)
      super(application_form:)
      @with_current_year_applications = with_current_year_applications
      @january_choice_state = january_choice_state
    end

    def render?
      true
    end

    def active_previous_application
      @active_previous_application ||= FactoryBot.build(
        :application_form,
        candidate: application_form.candidate,
        recruitment_cycle_year: application_form.recruitment_cycle_year - 1,
        created_at: application_form.created_at - 1.year,
      )
    end

    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider, code:)

        prev_jan_course = FactoryBot.build(:course, provider:, start_date: "01/01/#{application_form.recruitment_cycle_year}")
        prev_jan_course_option = FactoryBot.build(:course_option, course: prev_jan_course)
        FactoryBot.create(
          :application_choice,
          @january_choice_state,
          application_form: active_previous_application,
          course_option: prev_jan_course_option,
          current_recruitment_cycle_year: active_previous_application.recruitment_cycle_year,
        )

        if @with_current_year_applications
          sept_course = FactoryBot.build(:course, provider:)
          sept_course_option = FactoryBot.build(:course_option, course: sept_course)
          FactoryBot.create(:application_choice, application_form:, course_option: sept_course_option)

          jan_course = FactoryBot.build(:course, provider:, start_date: "01/01/#{application_form.recruitment_cycle_year + 1}")
          jan_course_option = FactoryBot.build(:course_option, course: jan_course)
          FactoryBot.create(:application_choice, application_form:, course_option: jan_course_option)
        end

        CandidateInterface::SortApplicationChoices.call(
          application_choices: @application_form.application_choices.for_sorting,
        )
      end
    end

    def code
      loop do
        random_code = SecureRandom.alphanumeric(3)
        break unless Provider.exists?(code: random_code)
      end
    end
  end
end
