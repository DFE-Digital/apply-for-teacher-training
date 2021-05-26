class ConfirmOfferConditions
  include ActiveModel::Validations
  include ImpersonationAuditHelper

  def initialize(actor:, application_choice:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
  end

  def save
    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.current_course_option.id)

    audit(@auth.actor) do
      ApplicationStateChange.new(@application_choice).confirm_conditions_met!
      @application_choice.update!(recruited_at: Time.zone.now)
      UpdateOfferConditions.new(application_choice: @application_choice).call
      CandidateMailer.conditions_met(@application_choice).deliver_later
      StateChangeNotifier.new(:recruited, @application_choice).application_outcome_notification
    end
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
