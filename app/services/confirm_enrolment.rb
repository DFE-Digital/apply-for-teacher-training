class ConfirmEnrolment
  include ActiveModel::Validations

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def save
    ApplicationStateChange.new(@application_choice).confirm_enrolment!
  rescue Workflow::NoTransitionAllowed => e
    errors.add(:state, e.message)
    false
  end
end
