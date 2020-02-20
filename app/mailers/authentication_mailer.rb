class AuthenticationMailer < ApplicationMailer
  def sign_up_email(candidate:, token:)
    @magic_link = "#{candidate_interface_authenticate_url}?token=#{token}"

    notify_email(
      to: candidate.email_address,
      subject: t('authentication.sign_up.email.subject'),
      reference: "#{HostingEnvironment.environment_name}-sign_up_email-#{candidate.id}",
    )
  end

  def sign_in_email(candidate:, token:)
    @magic_link = "#{candidate_interface_authenticate_url}?token=#{token}"

    notify_email(
      to: candidate.email_address,
      subject: t('authentication.sign_in.email.subject'),
    )
  end

  def sign_in_without_account_email(to:)
    notify_email(
      to: to,
      subject: t('authentication.sign_in_without_account.email.subject'),
    )
  end
end
