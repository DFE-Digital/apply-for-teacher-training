class RejectApplication
  include ActiveModel::Validations

  attr_accessor :rejection_reason

  validates_presence_of :rejection_reason
  validates_length_of :rejection_reason, maximum: 255

  def initialize(actor:, application_choice:, rejection_reason: nil)
    @auth = ProviderAuthorisation.new(actor: actor)
    @application_choice = application_choice
    @rejection_reason = rejection_reason
  end

  def save
    return unless valid?

    @auth.assert_can_make_decisions!(application_choice: @application_choice, course_option_id: @application_choice.offered_option.id)

    ActiveRecord::Base.transaction do
      ApplicationStateChange.new(@application_choice).reject!
      @application_choice.update!(
        rejection_reason: @rejection_reason,
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
