class RejectApplication
  include ActiveModel::Validations
  include ImpersonationAuditHelper

  # rejection_reason from Vendor API
  attr_accessor :rejection_reason, :structured_rejection_reasons

  validate :at_least_one_rejection_reason_format
  validates_length_of :rejection_reason, maximum: 65535

  def initialize(actor:, application_choice:, rejection_reason: nil, structured_rejection_reasons: nil)
    @auth = ProviderAuthorisation.new(actor:)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def save
    return false unless valid?

    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.current_course_option.id)

    audit(@auth.actor) do
      ActiveRecord::Base.transaction do
        ApplicationStateChange.new(@application_choice).reject!
        @application_choice.update!(
          rejection_reason: @rejection_reason,
          structured_rejection_reasons: @structured_rejection_reasons,
          rejection_reasons_type:,
          rejected_at: Time.zone.now,
        )
      end

      CancelUpcomingInterviews.new(actor: @auth.actor, application_choice: @application_choice, cancellation_reason: I18n.t('interview_cancellation.reason.application_rejected')).call!

      CandidateMailers::SendRejectionEmailWorker.perform_async(@application_choice.id)
    end

    true
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end

private

  def rejection_reasons_type
    return :rejection_reason if @structured_rejection_reasons.blank?

    structured_rejection_reasons.class.name.underscore.gsub('/', '_')
  end

  def at_least_one_rejection_reason_format
    if rejection_reason.blank? && structured_rejection_reasons.blank?
      errors.add(:rejection_reason, :blank)
    end
  end
end
