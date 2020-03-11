class Email < ApplicationRecord
  # Note that most, but not all, emails that we send are in regards to an
  # application form. For sign-ups and sign-ins application_form will be nil.
  belongs_to :application_form, optional: true

  enum delivery_status: {
    unknown: 'unknown',
    delivered: 'delivered',
    permanent_failure: 'permanent_failure',
    temporary_failure: 'temporary_failure',
    technical_failure: 'technical_failure',
  }

  def humanised_email_type
    "#{mail_template.humanize} (#{mailer.humanize})"
  end
end
