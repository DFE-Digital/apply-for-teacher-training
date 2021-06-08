class MakeOffer
  include ImpersonationAuditHelper

  STANDARD_CONDITIONS = ['Fitness to train to teach check', 'Disclosure and Barring Service (DBS) check'].freeze

  attr_reader :actor, :application_choice, :course_option, :persist_conditions_service

  def initialize(actor:,
                 application_choice:,
                 course_option:,
                 persist_conditions_service:)
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @persist_conditions_service = persist_conditions_service
  end

  def save!
    auth.assert_can_make_decisions!(application_choice: application_choice, course_option: course_option)

    if offer.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).make_offer!

          application_choice.current_course_option = course_option
          persist_conditions_service.save
          application_choice.offered_at = Time.zone.now
          application_choice.save!

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
                                    conditions: persist_conditions_service.conditions)
  end
end
