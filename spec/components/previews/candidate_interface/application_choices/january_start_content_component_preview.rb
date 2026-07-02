class CandidateInterface::ApplicationChoices::JanuaryStartContentComponentPreview < ViewComponent::Preview
  def default
    render PreviewJanuaryStartContentComponent.new(application_form:)
  end

  def winter_reject_by_default_approaching_awaiting_provider_decision
    render PreviewJanuaryStartContentComponent.new(application_form:, winter_reject_by_default_approaching: true)
  end

  def winter_reject_by_default_approaching_offered_placement
    render PreviewJanuaryStartContentComponent.new(application_form:, winter_reject_by_default_approaching: true, choice_state: :offered)
  end

  def after_reject_by_default
    render PreviewJanuaryStartContentComponent.new(application_form:, winter_reject_by_default_approaching: true, choice_state: :rejected_by_default)
  end

  def after_declined_by_default
    render PreviewJanuaryStartContentComponent.new(application_form:, winter_reject_by_default_approaching: true, choice_state: :declined_by_default)
  end

private

  def application_form
    @application_form ||= FactoryBot.create(:application_form)
  end

  class PreviewJanuaryStartContentComponent < CandidateInterface::ApplicationChoices::JanuaryStartContentComponent
    def initialize(application_form:, choice_state: :awaiting_provider_decision, winter_reject_by_default_approaching: false)
      super(application_form:)
      @choice_state = choice_state
      @winter_reject_by_default_approaching = winter_reject_by_default_approaching
    end

    def application_choices
      @application_choices ||= begin
        provider = FactoryBot.build(:provider, code:)
        course = FactoryBot.build(:course, provider:, start_date: "01/01/#{application_form.recruitment_cycle_year}")
        course_option = FactoryBot.build(:course_option, course: course)
        FactoryBot.create(:application_choice, @choice_state, application_form:, course_option:)

        CandidateInterface::SortApplicationChoices.call(
          application_choices: @application_form.application_choices.for_sorting,
        )
      end
    end

    def approaching_winter_reject_by_default_at?
      @winter_reject_by_default_approaching
    end

    def code
      loop do
        random_code = SecureRandom.alphanumeric(3)
        break unless Provider.exists?(code: random_code)
      end
    end
  end
end
