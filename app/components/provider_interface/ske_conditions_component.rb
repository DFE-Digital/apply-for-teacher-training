module ProviderInterface
  class SkeConditionsComponent < ViewComponent::Base
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
        { key: 'Length', value: "#{length} weeks" },
        { key: 'Reason', value: ske_condition_presenter.reason },
      ]
    end

    def subject
      (ske_condition.subject.presence || @course.subjects.first&.name)
    end

    def change_path
      edit_provider_interface_application_choice_offer_ske_requirements_path(
        application_choice,
      )
    end
  end
end
