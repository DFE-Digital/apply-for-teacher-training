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

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewMultipleActiveApplicationsContentComponent < CandidateInterface::MultipleActiveApplicationsContentComponent
    def initialize(application_form:, with_current_year_applications: true)
      super(application_form:)
      @with_current_year_applications = with_current_year_applications
    end

    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider)

        previous_application = FactoryBot.build(
          :application_form,
          candidate: application_form.candidate,
          recruitment_cycle_year: application_form.recruitment_cycle_year - 1,
          created_at: application_form.created_at - 1.year,
        )
        prev_jan_course = FactoryBot.build(:course, provider:, start_date: "01/01/#{application_form.recruitment_cycle_year}")
        prev_jan_course_option = FactoryBot.build(:course_option, course: prev_jan_course)
        FactoryBot.create(
          :application_choice,
          :awaiting_provider_decision,
          application_form: previous_application,
          course_option: prev_jan_course_option,
          current_recruitment_cycle_year: previous_application.recruitment_cycle_year,
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
  end
end
