class ConfirmDeferredOffer
  attr_reader :actor, :application_choice, :course_option, :conditions_met

  def initialize(actor:, application_choice:, course_option:, conditions_met:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @conditions_met = conditions_met
  end

  def save!
    service.new(actor: actor,
                application_choice: application_choice,
                course_option: course_option).save!
  end

  def save
    save!
    true
  rescue ValidationException, Workflow::NoTransitionAllowed
    false
  end

private

  def service
    conditions_met ? ReinstateConditionsMet : ReinstatePendingConditions
  end
end
