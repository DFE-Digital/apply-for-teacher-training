class ProviderMailer < ApplicationMailer
  def account_created(provider_user)
    @provider_user = provider_user

    notify_email(
      to: @provider_user.email_address,
      subject: t('provider_account_created.email.subject'),
    )
  end

  def application_submitted(provider_user, application_choice)
    @application =
      Struct.new(
        :course_name_and_code,
        :provider_user_name,
        :candidate_name,
        :application_choice_id,
        :rbd_days,
      ).new(
        application_choice.course.name_and_code,
        provider_user.full_name,
        application_choice.application_form.full_name,
        application_choice.id,
        application_choice.reject_by_default_days,
    )

    notify_email(
      to: provider_user.email_address,
      subject: t('provider_application_submitted.email.subject', course_name_and_code: @application.course_name_and_code),
      application_form_id: application_choice.application_form.id,
    )
  end

  def application_rejected_by_default(provider_user, application_choice)
    @application =
      Struct.new(
        :candidate_name,
        :provider_user_name,
        :course_name_and_code,
        :submitted_at,
        :application_choice,
        :rbd_days,
      ).new(
        application_choice.application_form.full_name,
        provider_user.full_name,
        application_choice.course.name_and_code,
        application_choice.application_form.submitted_at.to_s(:govuk_date).strip,
        application_choice,
        application_choice.reject_by_default_days,
    )

    notify_email(
      to: provider_user.email_address,
      subject: t('provider_application_rejected_by_default.email.subject', candidate_name: @application.candidate_name),
      application_form_id: application_choice.application_form.id,
    )
  end

  def chase_provider_decision(provider_user, application_choice)
    @application =
      Struct.new(
        :candidate_name,
        :provider_user_name,
        :course_name_and_code,
        :submitted_at,
        :application_choice,
        :rbd_date,
      ).new(
        application_choice.application_form.full_name,
        provider_user.full_name,
        application_choice.course.name_and_code,
        application_choice.application_form.submitted_at.to_s(:govuk_date).strip,
        application_choice,
        application_choice.reject_by_default_at,
    )

    notify_email(
      to: provider_user.email_address,
      subject: I18n.t!('provider_application_waiting_for_decision.email.subject', candidate_name: @application.candidate_name),
      application_form_id: application_choice.application_form.id,
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

private

  def email_for_provider(provider_user, application_form, args = {})
    @provider_user = provider_user

    notify_email(
      to: provider_user.email_address,
      subject: args[:subject],
      application_form_id: application_form.id,
    )
  end
end
