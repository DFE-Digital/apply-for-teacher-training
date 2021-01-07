class RejectApplication
  include ActiveModel::Validations
  include ImpersonationAuditHelper

  attr_accessor :rejection_reason, :structured_rejection_reasons

  validates_presence_of :rejection_reason, if: -> { structured_rejection_reasons.blank? }
  validates_presence_of :structured_rejection_reasons, if: -> { rejection_reason.blank? }
  validates_length_of :rejection_reason, maximum: 10240

  def initialize(actor:, application_choice:, rejection_reason: nil, structured_rejection_reasons: nil)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
    @structured_rejection_reasons = structured_rejection_reasons
  end

  def save
    return false unless valid?

    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    audit(@auth.actor) do
      ActiveRecord::Base.transaction do
        ApplicationStateChange.new(@application_choice).reject!
        @application_choice.update!(
          rejection_reason: @rejection_reason,
          structured_rejection_reasons: @structured_rejection_reasons,
          rejected_at: Time.zone.now,
        )
        SetDeclineByDefault.new(application_form: @application_choice.application_form).call
      end

      SendCandidateRejectionEmail.new(application_choice: @application_choice).call

      if @application_choice.application_form.ended_without_success?
        StateChangeNotifier.new(:rejected, @application_choice).application_outcome_notification
      end
    end
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
