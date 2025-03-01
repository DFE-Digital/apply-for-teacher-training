module SupportInterface
  class EmailSubscriptionForm
    include ActiveModel::Model

    attr_accessor :unsubscribed_from_emails, :audit_comment

    validates :unsubscribed_from_emails, presence: true
    validates :audit_comment, presence: true

    def save(application_form)
      return false unless valid?

      application_form.candidate.update!(unsubscribed_from_emails:, audit_comment:)
    end

    def self.build_from_application(application_form)
      new(
        unsubscribed_from_emails: application_form.candidate.unsubscribed_from_emails,
      )
    end
  end
end
