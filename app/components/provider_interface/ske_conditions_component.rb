module ProviderInterface
  class SkeConditionsComponent < ViewComponent::Base
    attr_reader :application_choice, :ske_condition
    delegate :reason, :length, to: :ske_condition

    def initialize(application_choice:, ske_condition:)
      @application_choice = application_choice
      @ske_condition = ske_condition
    end

    def summary_list_rows
      [
        { key: 'Subject', value: subject },
        { key: 'Length', value: "#{length} weeks", action: { visually_hidden_text: 'change ske length', href: new_provider_interface_application_choice_offer_ske_length_path } },
        { key: 'Reason', value: reason, action: { visually_hidden_text: 'change ske reason', href: new_provider_interface_application_choice_offer_ske_reason_path } },
      ]
    end

    def subject
      (ske_condition.language.presence || @application_choice.current_course.subjects.first&.name)
    end

    def remove_condition_path
      provider_interface_application_choice_offer_ske_requirements_path
    end
  end
end
