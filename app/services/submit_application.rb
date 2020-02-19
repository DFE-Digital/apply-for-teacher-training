class SubmitApplication
  attr_reader :application_form, :application_choices, :skip_emails

  REFEREE_BOT_EMAIL_ADDRESSES = ['refbot1@example.com', 'refbot2@example.com'].freeze

  def initialize(application_form, skip_emails: false)
    @application_form = application_form
    @application_choices = application_form.application_choices
    @skip_emails = skip_emails
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.update!(submitted_at: Time.zone.now)
      submit_application
    end

    CandidateMailer.application_submitted(application_form).deliver_later
    send_reference_request_email_to_referees(application_form)
    StateChangeNotifier.call(:submit_application, application_form: application_form)
    auto_approve_references_in_sandbox(application_form)
  end

private

  def send_reference_request_email_to_referees(application_form)
<<<<<<< HEAD
    application_form.application_references.includes(:application_form).each do |reference|
      RefereeMailer.reference_request_email(application_form, reference).deliver_later unless skip_emails
=======
    application_form.references.where(feedback: nil).each do |reference|
      RefereeMailer.reference_request_email(application_form, reference).deliver_later
>>>>>>> Spike into implementing Apply 2

      reference.update!(feedback_status: 'feedback_requested', requested_at: Time.zone.now)
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
    application_choices.each do |application_choice|
<<<<<<< HEAD
      SubmitApplicationChoice.new(application_choice).call
=======
      application_choice.edit_by = ApplicationDates.new(application_form).edit_by
      ApplicationStateChange.new(application_choice).submit!

      if application_form.apply_2? && application_form.references_complete?
        ApplicationStateChange.new(application_choice).references_complete!
      end
>>>>>>> Spike into implementing Apply 2
    end
  end
end
