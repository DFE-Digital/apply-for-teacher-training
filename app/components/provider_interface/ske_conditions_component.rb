module ProviderInterface
  class SkeConditionsComponent < ApplicationComponent
    attr_reader :application_choice, :course, :ske_condition, :editable, :ske_condition_presenter
    delegate :reason, :length, to: :ske_condition

    def initialize(application_choice:, course:, ske_condition:, editable:)
      @application_choice = application_choice
      @course = course
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
          action: editable ? { visually_hidden_text: 'change ske length', href: change_length_path } : {},
        },
        {
          key: 'Reason',
          value: ske_condition_presenter.reason,
          action: editable ? { visually_hidden_text: 'change ske reason', href: change_reason_path } : {},
        },
      ]
    end

    def subject
      ske_condition.subject.presence || @course.subjects.first&.name
    end

    def remove_condition_path
      if application_choice.offer?
        edit_provider_interface_application_choice_offer_ske_requirements_path(
          application_choice,
        )
      else
        new_provider_interface_application_choice_offer_ske_requirements_path(
          application_choice,
        )
      end
    end

    def change_reason_path
      if application_choice.offer?
        edit_provider_interface_application_choice_offer_ske_reason_path(
          application_choice,
        )
      else
        new_provider_interface_application_choice_offer_ske_reason_path(
          application_choice,
        )
      end
    end

    def change_length_path
      if application_choice.offer?
        edit_provider_interface_application_choice_offer_ske_length_path(
          application_choice,
        )
      else
        new_provider_interface_application_choice_offer_ske_length_path(
          application_choice,
        )
      end
    end

    def offer_accepted?
      @application_choice.accepted_choice?
    end
  end
end
