class ReinstateConditionsMet
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option

  def initialize(actor:, application_choice:, course_option:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
  end

  def save!
    auth.assert_can_make_decisions!(application_choice: application_choice,
                                    course_option: course_option)

    if deferred_offer.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).reinstate_conditions_met!

          application_choice.update_course_option_and_associated_fields!(
            course_option,
            other_fields: { recruited_at: recruited_at },
          )
          application_choice.offer.conditions.each(&:met!)
        end
        CandidateMailer.reinstated_offer(application_choice).deliver_later
      end
    else
      raise ValidationException, deferred_offer.errors.map(&:message)
    end
  end

  def save
    save!
    true
  rescue ValidationException, Workflow::NoTransitionAllowed
    false
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor: actor)
  end

  def deferred_offer
    @deferred_offer ||= ConfirmDeferredOfferValidations.new(course_option: course_option)
  end

  def recruited_at
    if application_choice.status_before_deferral == 'recruited'
      application_choice.recruited_at # conditions are 'still met'
    else
      Time.zone.now
    end
  end
end
