class WithdrawOffer
  include ActiveModel::Validations
  include ImpersonationAuditHelper

  attr_accessor :offer_withdrawal_reason

  validates_presence_of :offer_withdrawal_reason
  validates_length_of :offer_withdrawal_reason, maximum: 65535

  def initialize(actor:, application_choice:, offer_withdrawal_reason: nil)
    @auth = ProviderAuthorisation.new(actor:)
    @application_choice = application_choice
    @offer_withdrawal_reason = offer_withdrawal_reason
  end

  def save
    return false unless valid?

    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.current_course_option.id)

    audit(@auth.actor) do
      ActiveRecord::Base.transaction do
        ApplicationStateChange.new(@application_choice).withdraw_offer!
        @application_choice.update!(
          offer_withdrawal_reason: @offer_withdrawal_reason,
          offer_withdrawn_at: Time.zone.now,
        )
      end

      CandidateMailer.offer_withdrawn(@application_choice).deliver_later

      true
    end
  rescue Workflow::NoTransitionAllowed
    errors.add(
      :base,
      I18n.t('activerecord.errors.models.application_choice.attributes.status.invalid_transition'),
    )
    false
  end
end
