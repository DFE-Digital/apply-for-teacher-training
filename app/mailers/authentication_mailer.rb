class AuthenticationMailer < ApplicationMailer
  def sign_up_email(candidate:, token:)
    @magic_link = candidate_interface_authenticate_url(magic_link_params(token))

    notify_email(
      to: candidate.email_address,
      subject: t('authentication.sign_up.email.subject'),
      reference: "#{HostingEnvironment.environment_name}-sign_up_email-#{candidate.id}-#{SecureRandom.hex}",
    )
  end

  def sign_in_email(candidate:, token:)
    @magic_link = candidate_interface_authenticate_url(magic_link_params(token))
    @application_form = candidate.application_forms.order(:created_at).last

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

private

  def magic_link_params(token)
    {
      token: token,
    }
  end
end
