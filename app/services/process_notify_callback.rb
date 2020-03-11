class ProcessNotifyCallback
  def initialize(notify_reference:, status:)
    @environment, @email_type, @id = notify_reference.split('-')
    @notify_reference = notify_reference
    @status = status
    @not_found = false
  end

  def call
    return unless same_environment?

    update_email_log

    if reference_request_email? && permanent_failure_status?
      mark_reference_as_bounced
    end

    if sign_up_email? && permanent_failure_status?
      mark_user_as_bounced
    end
  rescue ActiveRecord::RecordNotFound
    @not_found = true
  end

  def not_found?
    @not_found
  end

private

  def same_environment?
    @environment == HostingEnvironment.environment_name
  end

  def update_email_log
    logged_email = Email.find_by(notify_reference: @notify_reference)
    return unless logged_email

    logged_email.update!(delivery_status: @status.underscore)
  end

  def mark_reference_as_bounced
    ActiveRecord::Base.transaction do
      reference = ApplicationReference.find(@id)

      reference.update!(feedback_status: 'email_bounced')

      SendNewRefereeRequestEmail.call(
        application_form: reference.application_form,
        reference: reference,
        reason: :email_bounced,
      )
    end
  end

  def mark_user_as_bounced
    candidate = Candidate.find(@id)
    candidate.update!(sign_up_email_bounced: true, hide_in_reporting: true)
  end

  def reference_request_email?
    @email_type == 'reference_request'
  end

  def sign_up_email?
    @email_type == 'sign_up_email'
  end

  def permanent_failure_status?
    @status == 'permanent-failure'
  end
end
