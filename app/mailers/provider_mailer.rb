class ProviderMailer < ApplicationMailer
  def account_created(provider_user)
    @provider_user = provider_user

    view_mail(
      GENERIC_NOTIFY_TEMPLATE,
      to: @provider_user.email_address,
      subject: t('provider_account_created.email.subject'),
    )
  end

  def application_submitted(provider_user, application_choice)
    @application = OpenStruct.new(
      course_name: application_choice.course.name,
      course_code: application_choice.course.code,
      provider_user_name: provider_user.full_name,
      candidate_name: application_choice.application_form.full_name,
      application_choice_id: application_choice.id,
    )

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: provider_user.email_address,
              subject: t('provider_application_submitted.email.subject', course_name: @application.course_name, course_code: @application.course_code))
  end
end
