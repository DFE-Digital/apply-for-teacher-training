module SupportInterface
  class ConditionsComponent < ViewComponent::Base
    attr_accessor :conditions, :application_choice
    delegate :reason, :length, to: :ske_condition

    def initialize(conditions:, application_choice:)
      @conditions = conditions
      @application_choice = application_choice
    end

    def ske_rows
      [
        { key: 'Subject', value: ske_condition.subject },
        {
          key: 'Length',
          value: "#{length} weeks",
        },
        {
          key: 'Reason',
          value: ske_condition_presenter.reason,
        },
      ]
    end

    def ske_condition
      application_choice.offer.ske_conditions.first
    end

    def ske_condition_presenter
      SkeConditionPresenter.new(ske_condition, interface: :support_interface)
    end

    def render_ske?
      (application_choice.offer? || application_choice.pending_conditions?) && application_choice.offer.ske_conditions.present?
    end
  end
end
