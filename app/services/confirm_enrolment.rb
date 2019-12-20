class ConfirmEnrolment
  include ActiveModel::Validations

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save
    ApplicationStateChange.new(@application_choice).confirm_enrolment!
    @application_choice.update!(enrolled_at: Time.zone.now)
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
