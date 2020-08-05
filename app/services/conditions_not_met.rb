class ConditionsNotMet
  include ActiveModel::Validations

  def initialize(actor:, application_choice:)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
  end

  def save
    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    ApplicationStateChange.new(@application_choice).conditions_not_met!
    @application_choice.update!(conditions_not_met_at: Time.zone.now)
    CandidateMailer.conditions_not_met(@application_choice).deliver_later
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
