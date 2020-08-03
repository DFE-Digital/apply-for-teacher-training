class ConfirmOfferConditions
  include ActiveModel::Validations

  def initialize(actor:, application_choice:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
  end

  def save
    @auth.assert_can_make_offer!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    ApplicationStateChange.new(@application_choice).confirm_conditions_met!
    @application_choice.update!(recruited_at: Time.zone.now)
    CandidateMailer.conditions_met(@application_choice).deliver_later
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
