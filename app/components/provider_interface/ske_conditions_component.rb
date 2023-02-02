module ProviderInterface
  class SkeConditionsComponent < ViewComponent::Base
    attr_reader :subject, :length, :reason

    def initialize(subject, length, reason)
      @subject = subject
      @length = length
      @reason = reason
    end

    def summary_list_rows
      [
        { key: 'Subject', value: subject },
        { key: 'Length', value: "#{length} weeks", action: { visually_hidden_text: 'change ske length', href: new_provider_interface_application_choice_offer_ske_length_path } },
        { key: 'Reason', value: reason, action: { visually_hidden_text: 'change ske reason', href: new_provider_interface_application_choice_offer_ske_reason_path } },
      ]
    end

    def remove_condition_path
      provider_interface_application_choice_offer_ske_standard_flow_path
    end
  end
end
