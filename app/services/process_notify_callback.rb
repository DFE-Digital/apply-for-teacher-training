class ProcessNotifyCallback
  EXPECTED_EMAIL_TYPES = %w[reference_request sign_up_email].freeze

  def initialize(notify_reference:, status:)
    @environment, @email_type, @id = notify_reference.split('-')
    @status = status
    @not_found = false
  end

  def call
    return unless same_environment? && expected_email_type? && permanent_failure_status?

    if reference_request_email?
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

    if sign_up_email?
      candidate = Candidate.find(@id)

      candidate.update!(sign_up_email_bounced: true, hide_in_reporting: true)
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

  def expected_email_type?
    EXPECTED_EMAIL_TYPES.include?(@email_type)
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
