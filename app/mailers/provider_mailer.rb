class ProviderMailer < ApplicationMailer
  layout 'provider_email_with_footer', except: %i[fallback_sign_in_email]
  layout 'provider_email', only: %i[application_rejected_by_default application_submitted
                                    application_submitted_with_safeguarding_issues apply_service_is_now_open
                                    chase_provider_decision]

  def confirm_sign_in(provider_user, device:)
    @provider_user = provider_user
    @device = device

    provider_notify_email(
      to: provider_user.email_address,
      subject: I18n.t!('provider_mailer.confirm_sign_in.subject'),
    )
  end

  def fallback_sign_in_email(provider_user, token)
    @token = token

    provider_notify_email(
      to: provider_user.email_address,
      subject: t('authentication.sign_in.email.subject'),
    )
  end

  def application_submitted(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(provider_user,
                       application_choice.application_form,
                       subject: I18n.t!('provider_mailer.application_submitted.subject',
                                        candidate_name: @application.candidate_name,
                                        course_name: @application.course_name))
  end

  def application_submitted_with_safeguarding_issues(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_submitted_with_safeguarding_issues.subject',
                       candidate_name: @application.candidate_name,
                       course_name: @application.course_name),
    )
  end

  def application_rejected_by_default(provider_user, application_choice, can_make_decisions:)
    @application = map_application_choice_params(application_choice)
    @provider_can_give_feedback = can_make_decisions

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_rejected_by_default.subject', candidate_name: @application.candidate_name),
    )
  end

  def chase_provider_decision(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)
    @working_days_left = Time.zone.now.to_date.business_days_until(application_choice.reject_by_default_at.to_date)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.chase_provider_decision.subject', candidate_name: @application.candidate_name, course_name: @application.course_name),
    )
  end

  def offer_accepted(provider_user, application_choice)
    @application_choice = application_choice

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.offer_accepted.subject', candidate_name: application_choice.application_form.full_name, support_reference: @application_choice.application_form.support_reference),
    )
  end

  def unconditional_offer_accepted(provider_user, application_choice)
    @application_choice = application_choice

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!(
        'provider_mailer.unconditional_offer_accepted.subject',
        candidate_name: application_choice.application_form.full_name,
        support_reference: @application_choice.application_form.support_reference,
      ),
    )
  end

  def declined_by_default(provider_user, application_choice)
    @application_choice = application_choice
    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.decline_by_default.subject', candidate_name: application_choice.application_form.full_name, support_reference: @application_choice.application_form.support_reference),
    )
  end

  def application_withdrawn(provider_user, application_choice, number_of_cancelled_interviews = 0)
    @application_choice = application_choice
    @number_of_cancelled_interviews = number_of_cancelled_interviews

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_withdrawn.subject', candidate_name: application_choice.application_form.full_name, support_reference: @application_choice.application_form.support_reference),
    )
  end

  def declined(provider_user, application_choice)
    @application_choice = application_choice
    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.declined.subject', candidate_name: application_choice.application_form.full_name, support_reference: @application_choice.application_form.support_reference),
    )
  end

  def organisation_permissions_set_up(provider_user, provider, permissions)
    @provider_user = provider_user
    @recipient_organisation = provider
    @permissions = permissions
    @partner_organisation = permissions.partner_organisation(provider)

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.organisation_permissions_set_up.subject', provider: @partner_organisation.name),
    )
  end

  def organisation_permissions_updated(provider_user, provider, permissions)
    @provider_user = provider_user
    @recipient_organisation = provider
    @permissions = permissions
    @partner_organisation = permissions.partner_organisation(provider)

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.organisation_permissions_updated.subject', provider: @partner_organisation.name),
    )
  end

  def permissions_granted(provider_user, provider, permissions, permissions_granted_by = nil)
    @provider_user = provider_user
    @provider = provider
    @permissions_granted_by = permissions_granted_by
    @permissions = permissions

    email_attributes = if @permissions_granted_by
                         { subject: I18n.t!('provider_mailer.permissions_granted.subject',
                                            permissions_granted_by_user: @permissions_granted_by.full_name,
                                            organisation: @provider.name) }
                       else
                         { subject: I18n.t!('provider_mailer.permissions_granted_by_support.subject',
                                            organisation: @provider.name) }
                       end

    provider_notify_email({ to: @provider_user.email_address }.merge!(email_attributes))
  end

  def permissions_updated(provider_user, provider, permissions, permissions_updated_by = nil)
    @provider_user = provider_user
    @provider = provider
    @permissions_updated_by = permissions_updated_by
    @permissions = permissions

    email_attributes = if @permissions_updated_by
                         { subject: I18n.t!('provider_mailer.permissions_updated.subject',
                                            permissions_updated_by_user: @permissions_updated_by.full_name,
                                            organisation: @provider.name) }
                       else
                         { subject: I18n.t!('provider_mailer.permissions_updated_by_support.subject',
                                            organisation: @provider.name) }
                       end

    provider_notify_email({ to: @provider_user.email_address }.merge!(email_attributes))
  end

  def permissions_removed(provider_user, provider, permissions_removed_by = nil)
    @provider_user = provider_user
    @provider = provider
    @permissions_removed_by = permissions_removed_by

    if @permissions_removed_by
      provider_notify_email(to: @provider_user.email_address,
                            subject: I18n.t!('provider_mailer.permissions_removed.subject',
                                             permissions_removed_by_user: @permissions_removed_by.full_name,
                                             organisation: @provider.name))
    else
      provider_notify_email(to: @provider_user.email_address,
                            subject: I18n.t!('provider_mailer.permissions_removed_by_support.subject',
                                             organisation: @provider.name))
    end
  end

  def set_up_organisation_permissions(provider_user, relationships_to_set_up)
    @provider_user = provider_user
    @relationships_to_set_up = relationships_to_set_up
    @single_or_multiple = @relationships_to_set_up.keys.size > 1 ? 'multiple' : 'single'

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.set_up_organisation_permissions.subject'),
    )
  end

  def apply_service_is_now_open(provider_user)
    @provider_user = provider_user

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.apply_service_is_now_open.subject', time_period: CycleTimetable.cycle_year_range),
    )
  end

  def find_service_is_now_open(provider_user)
    @provider_user = provider_user

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.find_service_is_now_open.subject', time_period: CycleTimetable.cycle_year_range),
    )
  end

private

  def email_for_provider(provider_user, application_form, args = {})
    @provider_user = provider_user
    @provider_user_name = provider_user.full_name

    provider_notify_email(args.merge(to: provider_user.email_address,
                                     application_form_id: application_form.id))
  end

  def provider_notify_email(args)
    subject = I18n.t('provider_mailer.subject', subject: args[:subject])
    args.merge!(subject: subject)

    notify_email(args)
  end

  def map_application_choice_params(application_choice)
    Struct.new(
      :candidate_name,
      :course_name_and_code,
      :course_name,
      :submitted_at,
      :application_choice_id,
      :application_choice,
      :rbd_date,
      :rbd_days,
      :support_reference,
    ).new(
      application_choice.application_form.full_name,
      application_choice.current_course_option.course.name_and_code,
      application_choice.current_course_option.course.name,
      application_choice.application_form.submitted_at.to_s(:govuk_date).strip,
      application_choice.id,
      application_choice,
      application_choice.reject_by_default_at.to_s(:govuk_date),
      application_choice.reject_by_default_days,
      application_choice.application_form.support_reference,
    )
  end
end
