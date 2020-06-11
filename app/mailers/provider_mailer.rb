class ProviderMailer < ApplicationMailer
  def account_created(provider_user)
    @provider_user = provider_user

    notify_email(
      to: @provider_user.email_address,
      subject: t('provider_account_created.email.subject'),
    )
  end

  def application_submitted(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_application_submitted.email.subject', course_name_and_code: @application.course_name_and_code),
    )
  end

  def application_rejected_by_default(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_application_rejected_by_default.email.subject', candidate_name: @application.candidate_name),
    )
  end

  def chase_provider_decision(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)
    @working_days_left = Time.zone.now.to_date.business_days_until(application_choice.reject_by_default_at.to_date)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_application_waiting_for_decision.email.subject', candidate_name: @application.candidate_name),
    )
  end

  def offer_accepted(provider_user, application_choice)
    @application_choice = application_choice

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.offer_accepted.subject', candidate_name: application_choice.application_form.full_name),
    )
  end

  def declined_by_default(provider_user, application_choice)
    @application_choice = application_choice
    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.decline_by_default.subject', candidate_name: application_choice.application_form.full_name),
    )
  end

  def application_withrawn(provider_user, application_choice)
    @application_choice = application_choice

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_application_withrawnn.email.subject', candidate_name: application_choice.application_form.full_name),
    )
  end

  def declined(provider_user, application_choice)
    @application_choice = application_choice
    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.declined.subject', candidate_name: application_choice.application_form.full_name),
    )
  end

  def fallback_sign_in_email(provider_user, token)
    @magic_link = provider_interface_authenticate_with_token_url(token: token)
    @provider_user = provider_user
    @provider_user_name = provider_user.full_name

    notify_email(
      to: provider_user.email_address,
      subject: t('authentication.sign_in.email.subject'),
    )
  end

private

  def email_for_provider(provider_user, application_form, args = {})
    @provider_user = provider_user
    @provider_user_name = provider_user.full_name

    notify_email(args.merge(
                   to: provider_user.email_address,
                   application_form_id: application_form.id,
                 ))
  end

  def map_application_choice_params(application_choice)
    Struct.new(
      :candidate_name,
      :course_name_and_code,
      :submitted_at,
      :application_choice_id,
      :application_choice,
      :rbd_date,
      :rbd_days,
    ).new(
      application_choice.application_form.full_name,
      application_choice.course.name_and_code,
      application_choice.application_form.submitted_at.to_s(:govuk_date).strip,
      application_choice.id,
      application_choice,
      application_choice.reject_by_default_at,
      application_choice.reject_by_default_days,
    )
  end
end
