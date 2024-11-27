class AccountRecoveryMailer < ApplicationMailer
  helper UtmLinkHelper

  def send_code(email:, code:)
    @code = code
    @account_recovery_url = candidate_interface_account_recovery_new_url

    mailer_options = {
      to: email,
      subject: 'Account recovery',
    }
    notify_email(mailer_options)
  end
end
