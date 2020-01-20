class ProcessNotifyCallback
  class << self
    def call(notify_reference:, status:)
      @environment, @email_type, reference_id = notify_reference.split('-')
      @status = status

      return :not_updated unless same_environment? && reference_request_email? && permanent_failure_status?
      return :not_found unless ApplicationReference.exists?(reference_id)

      ApplicationReference.find_by(id: reference_id).update!(feedback_status: 'email_bounced')

      :updated
    end

  private

    def same_environment?
      @environment == HostingEnvironment.environment_name
    end

    def reference_request_email?
      @email_type == 'reference_request'
    end

    def permanent_failure_status?
      @status == 'permanent-failure'
    end
  end
end
