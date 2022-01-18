class ReinstateDeferredOffer
  attr_reader :actor, :application_choice, :course_option, :conditions_met

  def initialize(actor:, application_choice:, conditions_met:)
    @actor = actor
    @application_choice = application_choice
    @course_option = application_choice.current_course_option.in_next_cycle
    @conditions_met = conditions_met
  end

  def call
    raise ValidationException, ['The offered course does not exist in this recruitment cycle'] if course_option.nil?

    service_call = service_class.new(actor: actor,
                                     application_choice: application_choice,
                                     course_option: course_option)

    raise ValidationException, service_call.errors.map(&:message) unless service_call.save
  end

private

  def service_class
    conditions_met ? ReinstateConditionsMet : ReinstatePendingConditions
  end
end
