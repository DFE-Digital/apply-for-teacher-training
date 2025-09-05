module SupportInterface
  class ConditionsComponent < ApplicationComponent
    attr_accessor :conditions, :application_choice

    def initialize(conditions:, application_choice:)
      @conditions = conditions
      @application_choice = application_choice
    end

    def ske_rows(ske_condition)
      [
        { key: 'Subject', value: ske_condition.subject },
        {
          key: 'Length',
          value: "#{ske_condition.length} weeks",
        },
        {
          key: 'Reason',
          value: ske_condition_presenter(ske_condition).reason,
        },
      ]
    end

    def ske_conditions
      application_choice.offer.ske_conditions
    end

    def ske_condition_presenter(ske_condition)
      SkeConditionPresenter.new(ske_condition, interface: :support_interface)
    end

    def render_ske?
      (application_choice.offer? || application_choice.pending_conditions?) && application_choice.offer.ske_conditions.present?
    end
  end
end
