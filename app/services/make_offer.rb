class MakeOffer
  include ImpersonationAuditHelper

  attr_reader :actor, :application_choice, :course_option, :conditions

  def initialize(actor:,
                 application_choice:,
                 course_option:,
                 conditions: [])
    @actor = actor
    @application_choice = application_choice
    @course_option = course_option
    @conditions = conditions
  end

  def save!
    auth.assert_can_make_decisions!(application_choice: application_choice, course_option: course_option)

    if offer.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).make_offer!

          application_choice.current_course_option = course_option
          application_choice.offer = { 'conditions' => conditions }
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
                                    conditions: conditions)
  end
end
