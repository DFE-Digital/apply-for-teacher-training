class ProviderMailer < ApplicationMailer
  layout 'provider_email'

  def confirm_sign_in(provider_user, timestamp:)
    @provider_user = provider_user
    @date = timestamp.to_fs(:govuk_date)
    @time = timestamp.to_fs(:govuk_time)

    provider_notify_email(
      to: provider_user.email_address,
      subject: I18n.t!('provider_mailer.confirm_sign_in.subject'),
    )
  end

  def fallback_sign_in_email(provider_user, token)
    @provider_user = provider_user
    @token = token

    provider_notify_email(
      to: provider_user.email_address,
      subject: t('provider_mailer.fallback-sign_in.subject'),
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

  def reference_received(provider_user:, application_choice:, reference:, course:)
    @reference = reference
    @candidate_name = reference.application_form.full_name
    @course_name_and_code = course.name_and_code
    @link = provider_interface_application_choice_references_url(application_choice_id: application_choice.id)
    @ordinance = TextOrdinalizer.call(reference.order_in_application_references)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!(
        'provider_mailer.reference_received.subject',
        candidate_name: @candidate_name,
        ordinance: @ordinance,
      ),
    )
  end

  def offer_accepted(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.offer_accepted.subject', candidate_name: @application.candidate_name, course_name: @application.course_name),
    )
  end

  def unconditional_offer_accepted(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!(
        'provider_mailer.unconditional_offer_accepted.subject',
        candidate_name: @application.candidate_name,
        course_name: @application.course_name,
      ),
    )
  end

  def declined_by_default(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)
    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.decline_by_default.subject', candidate_name: @application.candidate_name, course_name: @application.course_name),
    )
  end

  def application_withdrawn(provider_user, application_choice, number_of_cancelled_interviews = 0)
    @application = map_application_choice_params(application_choice)
    @number_of_cancelled_interviews = number_of_cancelled_interviews

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_withdrawn.subject', candidate_name: @application.candidate_name),
    )
  end

  def declined(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)
    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.declined.subject', candidate_name: @application.candidate_name),
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
    @recruitment_cycle = current_timetable.cycle_range_name

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.apply_service_is_now_open.subject', time_period: @recruitment_cycle),
    )
  end

  def find_service_is_now_open(provider_user)
    @provider_user = provider_user
    @recruitment_cycle = current_timetable.cycle_range_name
    @apply_opens = current_timetable.apply_opens_at.to_fs(:govuk_date)

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!('provider_mailer.find_service_is_now_open.subject', time_period: @recruitment_cycle),
    )
  end

  def respond_to_applications_before_reject_by_default_date(provider_user)
    @provider_user = provider_user
    @reject_by_default_date = I18n.l(current_timetable.reject_by_default_at.to_date, format: :no_year)
    @decline_by_default_date = I18n.l(current_timetable.decline_by_default_at.to_date, format: :no_year)
    @notifications_url = provider_interface_notifications_url
    @applications_url = provider_interface_applications_url

    provider_notify_email(
      to: @provider_user.email_address,
      subject: I18n.t!(
        'provider_mailer.respond_to_applications_before_reject_by_default_date.subject',
        reject_by_default_date: @reject_by_default_date,
      ),
    )
  end

private

  def current_timetable
    @current_timetable = RecruitmentCycleTimetable.current_timetable
  end

  def email_for_provider(provider_user, application_form, args = {})
    @provider_user = provider_user
    @provider_user_name = provider_user.full_name

    provider_notify_email(args.merge(to: provider_user.email_address,
                                     application_form_id: application_form.id))
  end

  def provider_notify_email(args)
    subject = I18n.t('provider_mailer.subject', subject: args[:subject])
    args.merge!(subject:)

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
      :support_reference,
    ).new(
      application_choice.application_form.full_name,
      application_choice.current_course_option.course.name_and_code,
      application_choice.current_course_option.course.name,
      application_choice.application_form.submitted_at&.to_fs(:govuk_date),
      application_choice.id,
      application_choice,
      application_choice.application_form.support_reference,
    )
  end
end
