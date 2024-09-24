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
    auth.assert_can_make_decisions!(application_choice:, course_option:)

    if offer.valid?
      audit(actor) do
        ActiveRecord::Base.transaction do
          ApplicationStateChange.new(application_choice).make_offer!

          update_conditions_service.save

          application_choice.update_course_option_and_associated_fields!(
            course_option,
            other_fields: { offered_at: Time.zone.now },
          )
        end

        CancelUpcomingInterviews.new(
          actor:,
          application_choice:,
          cancellation_reason: I18n.t('interview_cancellation.reason.offer_made'),
        ).call!

        SendNewOfferEmailToCandidate.new(application_choice:).call
      end
    else
      raise ValidationException, offer.errors.map(&:message)
    end
  end

private

  def auth
    @auth ||= ProviderAuthorisation.new(actor:)
  end

  def offer
    @offer ||= OfferValidations.new(
      application_choice:,
      course_option:,
      conditions: update_conditions_service.conditions,
      structured_conditions: update_conditions_service.try(:structured_conditions),
    )
  end
end
