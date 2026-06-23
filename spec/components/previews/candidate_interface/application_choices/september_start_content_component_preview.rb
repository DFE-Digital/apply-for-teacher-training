class CandidateInterface::ApplicationChoices::SeptemberStartContentComponentPreview < ViewComponent::Preview
  def applications_awaiting_provider_decisions
    render PreviewSeptemberStartContentComponent.new(application_form:)
  end

  def what_happens_next?
    render PreviewSeptemberStartContentComponent.new(
      application_form:,
      heading: 'What happens next?',
      heading_class: 'govuk-heading-m',
      with_tabs: true,
    )
  end

  def after_reject_by_default
    render PreviewSeptemberStartContentComponent.new(application_form:, after_reject_by_default: true, choice_state: :rejected_by_default)
  end

  def after_decline_by_default
    render PreviewSeptemberStartContentComponent.new(application_form:, after_reject_by_default: true, after_decline_by_default: true, choice_state: :declined_by_default)
  end

  def applications_offered
    render PreviewSeptemberStartContentComponent.new(application_form:, choice_state: :offered)
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewSeptemberStartContentComponent < CandidateInterface::ApplicationChoices::SeptemberStartContentComponent
    def initialize(application_form:, heading: nil, heading_class: 'govuk-heading-l', after_reject_by_default: false,
                   after_decline_by_default: false, choice_state: :awaiting_provider_decision, with_tabs: false)
      super(application_form:, heading:, heading_class:, with_tabs:)
      @after_reject_by_default = after_reject_by_default
      @after_decline_by_default = after_decline_by_default
      @choice_state = choice_state
    end

    def after_reject_by_default?
      @after_reject_by_default
    end

    def after_decline_by_default?
      @after_decline_by_default
    end

    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider, code:)
        course = FactoryBot.build(:course, provider:)
        course_option = FactoryBot.build(:course_option, course: course)
        FactoryBot.create(:application_choice, @choice_state, application_form:, course_option:)

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
