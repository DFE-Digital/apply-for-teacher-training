class ReinstateConditionsMet
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option, :offer_changed

  def initialize(actor:, application_choice:, course_option:, offer_changed:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @offer_changed = offer_changed
  end

  def save!
    if deferred_offer.valid?
      auth.assert_can_make_decisions!(application_choice:,
                                      course_option:)

      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).reinstate_conditions_met!

          application_choice.update_course_option_and_associated_fields!(
            course_option,
            other_fields: { recruited_at: },
          )
          application_choice.offer.conditions.each(&:met!)
        end

        if offer_changed
          CandidateMailer.deferred_offer_new_details(application_choice, conditions_met: true).deliver_later
        else
          CandidateMailer.reinstated_offer(application_choice).deliver_later
        end
      end
    else
      raise ValidationException, deferred_offer.errors.map(&:message)
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor:)
  end

  def deferred_offer
    @deferred_offer ||= ConfirmDeferredOfferValidations.new(course_option:)
  end

  def recruited_at
    if application_choice.status_before_deferral == 'recruited'
      application_choice.recruited_at # conditions are 'still met'
    else
      Time.zone.now
    end
  end
end
