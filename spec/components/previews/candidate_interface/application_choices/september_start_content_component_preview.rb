class CandidateInterface::ApplicationChoices::SeptemberStartContentComponentPreview < ViewComponent::Preview
  def applications_awaiting_provider_decisions
    render PreviewSeptemberStartContentComponent.new(application_form:)
  end

  def after_reject_by_default
    render PreviewSeptemberStartContentComponent.new(application_form:, choice_state: :rejected_by_default)
  end

  def after_decline_by_default
    render PreviewSeptemberStartContentComponent.new(application_form:, choice_state: :declined_by_default)
  end

  def applications_offered
    render PreviewSeptemberStartContentComponent.new(application_form:, choice_state: :offered)
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewSeptemberStartContentComponent < CandidateInterface::ApplicationChoices::SeptemberStartContentComponent
    include PreviewProviderHelper

    def initialize(application_form:, choice_state: :awaiting_provider_decision, with_tabs: false)
      super(application_form:, with_tabs:)
      @choice_state = choice_state
    end

    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider, code: unique_provider_code)
        course = FactoryBot.build(:course, provider:)
        course_option = FactoryBot.build(:course_option, course: course)
        FactoryBot.create(:application_choice, @choice_state, application_form:, course_option:)

        CandidateInterface::SortApplicationChoices.call(
          application_choices: @application_form.application_choices.for_sorting,
        )
      end
    end
  end
end
