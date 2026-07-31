module CandidateInterface
  class InlineApplicationChoiceButtonsComponentPreview < ViewComponent::Preview
    def no_application_choices
      render CandidateInterface::InlineApplicationChoiceButtonsComponent.new(application_form:)
    end

    def one_application_choice
      render InlineApplicationChoiceButtonsPreviewComponent.new(application_form:)
    end

    def many_application_choices
      render InlineApplicationChoiceButtonsPreviewComponent.new(application_form:, num_application_choices: 2)
    end

    def max_application_choices
      render InlineApplicationChoiceButtonsPreviewComponent.new(application_form:, num_application_choices: 4)
    end

  private

    def application_form(state: nil)
      FactoryBot.build(:application_form, state)
    end

    class InlineApplicationChoiceButtonsPreviewComponent < CandidateInterface::InlineApplicationChoiceButtonsComponent
      def initialize(application_form:, num_application_choices: 1, application_choice_status: :unsubmitted)
        super(application_form:)
        @num_application_choices = num_application_choices
        @application_choice_status = application_choice_status
      end

      def application_choices
        FactoryBot.build_stubbed_list(:application_choice, @num_application_choices, @application_choice_status)
      end

      def can_add_more_choices?
        application_choices.size < 4
      end
    end
  end
end
