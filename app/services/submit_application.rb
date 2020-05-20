class SubmitApplication
  attr_reader :application_form, :application_choices

  REFEREE_BOT_EMAIL_ADDRESSES = ['refbot1@example.com', 'refbot2@example.com'].freeze

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    ActiveRecord::Base.transaction do
      if FeatureFlag.active?('move_edit_by_to_application_form')
        if application_form.apply_again? && enough_references_have_been_provided?
          application_form.update!(submitted_at: Time.zone.now, edit_by: Time.zone.now)
        else
          application_form.update!(submitted_at: Time.zone.now)
          application_form.update!(edit_by: edit_by_time)
        end

      else
        application_form.update!(submitted_at: Time.zone.now)
        application_form.update!(edit_by: edit_by_time)
      end
      submit_application
    end

    CandidateMailer.application_submitted(application_form).deliver_later
    send_reference_request_email_to_referees(application_form)
    StateChangeNotifier.call(:submit_application, application_form: application_form)
    auto_approve_references_in_sandbox(application_form)
  end

private

  def send_reference_request_email_to_referees(application_form)
    application_form.application_references.not_requested_yet.includes(:application_form).each do |reference|
      CandidateInterface::RequestReference.call(reference)
    end
  end

  def auto_approve_references_in_sandbox(application_form)
    application_form.application_references.includes(:application_form).each do |reference|
      auto_approve_reference(reference) if HostingEnvironment.sandbox_mode? && email_address_is_a_bot?(reference)
    end
  end

  def auto_approve_reference(reference)
    reference.update!(
      relationship_correction: '',
      safeguarding_concerns: '',
      feedback: I18n.t('new_referee_request.auto_approve_feedback'),
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def email_address_is_a_bot?(reference)
    REFEREE_BOT_EMAIL_ADDRESSES.include?(reference.email_address)
  end

  def submit_application
    application_choices.each do |choice|
      SubmitApplicationChoice.new(
        choice,
        apply_again: application_form.apply_again?,
        enough_references: enough_references_have_been_provided?,
      ).call
    end
  end

  def enough_references_have_been_provided?
    application_form
      .application_references
      .feedback_provided
      .uniq
      .count >= ApplicationForm::MINIMUM_COMPLETE_REFERENCES
  end

  def edit_by_time
    if HostingEnvironment.sandbox_mode?
      Time.zone.now
    else
      TimeLimitConfig.edit_by.to_days.after(application_form.submitted_at).end_of_day
    end
  end
end
