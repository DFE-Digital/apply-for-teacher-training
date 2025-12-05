class ConfirmDeferredOffer
  attr_reader :actor, :application_choice, :course_option, :conditions_met, :offer_changed

  def initialize(actor:, application_choice:, course_option:, conditions_met:, offer_changed: false)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @conditions_met = conditions_met
    @offer_changed = offer_changed
  end

  def save!
    service.new(actor:,
                application_choice:,
                course_option:,
                offer_changed:).save!
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
