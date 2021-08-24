class MakeOffer
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option, :update_conditions_service

  def initialize(actor:,
                 application_choice:,
                 course_option:,
                 update_conditions_service:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @update_conditions_service = update_conditions_service
  end

  def save!
    auth.assert_can_make_decisions!(application_choice: application_choice, course_option: course_option)

    if offer.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).make_offer!

          update_conditions_service.save

          application_choice.update_course_option!(
            course_option,
            other_fields: { offered_at: Time.zone.now },
          )

          SetDeclineByDefault.new(application_form: application_choice.application_form).call
        end

        SendNewOfferEmailToCandidate.new(application_choice: application_choice).call
      end
    else
      raise ValidationException, offer.errors.map(&:message)
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor: actor)
  end

  def offer
    @offer ||= OfferValidations.new(course_option: course_option,
                                    conditions: update_conditions_service.conditions)
  end
end
