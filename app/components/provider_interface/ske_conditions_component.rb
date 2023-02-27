module ProviderInterface
  class SkeConditionsComponent < ViewComponent::Base
    attr_reader :application_choice, :ske_condition, :editable, :ske_condition_presenter
    delegate :subject, :reason, :length, to: :ske_condition

    def initialize(application_choice:, ske_condition:, editable:)
      @application_choice = application_choice
      @editable = editable
      @ske_condition = ske_condition
      @ske_condition_presenter = SkeConditionPresenter.new(
        ske_condition,
        interface: :provider_interface,
      )
    end

    def summary_list_rows
      [
        { key: 'Subject', value: subject },
        {
          key: 'Length',
          value: "#{length} weeks",
          action: editable ? { visually_hidden_text: 'change ske length', href: new_provider_interface_application_choice_offer_ske_length_path(application_choice) } : {},
        },
        {
          key: 'Reason',
          value: ske_condition_presenter.reason,
          action: editable ? { visually_hidden_text: 'change ske reason', href: new_provider_interface_application_choice_offer_ske_reason_path(application_choice) } : {},
        },
      ]
    end

    def remove_condition_path
      new_provider_interface_application_choice_offer_ske_requirements_path(application_choice)
    end
  end
end
