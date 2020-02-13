class RejectApplication
  include ActiveModel::Validations

  attr_accessor :rejection_reason

  validates_presence_of :rejection_reason
  validates_length_of :rejection_reason, maximum: 255

  def initialize(application_choice:, rejection_reason: nil)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
  end

  def save
    return unless valid?

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reject!
      @application_choice.update!(
        rejection_reason: @rejection_reason,
        rejected_at: Time.zone.now,
      )
      if FeatureFlag.active?('candidate_rejected_by_provider_email')
        SendCandidateRejectionEmail.call(application_choice: @application_choice)
      end
      SetDeclineByDefault.new(application_form: @application_choice.application_form).call
      StateChangeNotifier.call(:reject_application, application_choice: @application_choice)
    end
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
