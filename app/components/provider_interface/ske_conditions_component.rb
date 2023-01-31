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
        { key: 'Length', value: "#{length} weeks", action: { visually_hidden_text: 'change ske length', href: provider_interface_application_choice_offer_ske_length_path } },
        { key: 'Reason', value: reason, action: { visually_hidden_text: 'change ske reason', href: provider_interface_application_choice_offer_ske_reason_path } },
      ]
    end
  end
end
