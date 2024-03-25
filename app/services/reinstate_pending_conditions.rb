class ReinstatePendingConditions
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option

  def initialize(actor:, application_choice:, course_option:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
  end

  def save!
    if deferred_offer.valid?
      auth.assert_can_make_decisions!(application_choice:,
                                      course_option:)

      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).reinstate_pending_conditions!

          application_choice.offer.conditions.each(&:pending!)
          application_choice.update_course_option_and_associated_fields!(
            course_option,
            other_fields: { recruited_at: nil },
          )
        end
        CandidateMailer.reinstated_offer(application_choice).deliver_later
      end
    else
      raise ValidationException, deferred_offer.errors.map(&:message)
    end
  end

private

  def deferred_offer
    @deferred_offer ||= ConfirmDeferredOfferValidations.new(course_option:)
  end

  def auth
    @auth ||= ProviderAuthorisation.new(actor:)
  end
end
