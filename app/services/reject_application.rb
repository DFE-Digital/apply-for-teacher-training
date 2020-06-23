class RejectApplication
  include ActiveModel::Validations

  attr_accessor :rejection_reasons

  validates_presence_of :rejection_reasons

  def initialize(application_choice:, rejection_reasons: nil)
    @application_choice = application_choice
    @rejection_reasons = rejection_reasons
  end

  def save
    return unless valid?

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reject!
      @application_choice.update!(
        structured_rejection_reasons: @rejection_reasons,
        rejected_at: Time.zone.now,
      )
      SetDeclineByDefault.new(application_form: @application_choice.application_form).call
    end

    StateChangeNotifier.call(:reject_application, application_choice: @application_choice)
    SendCandidateRejectionEmail.new(application_choice: @application_choice).call
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
