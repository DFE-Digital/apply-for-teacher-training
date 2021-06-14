class ChangeOffer
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

          application_choice.current_course_option = course_option
          application_choice.offer = { 'conditions' => update_conditions_service.conditions }
          application_choice.offer_changed_at = Time.zone.now
          application_choice.save!

          SetDeclineByDefault.new(application_form: application_choice.application_form).call
        end

        CandidateMailer.changed_offer(application_choice).deliver_later
        StateChangeNotifier.call(:change_an_offer, application_choice: application_choice)
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
    @offer ||= OfferValidations.new(application_choice: application_choice,
                                    course_option: course_option,
                                    conditions: update_conditions_service.conditions)
  end
end
