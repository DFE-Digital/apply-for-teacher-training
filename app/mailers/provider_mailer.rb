class ProviderMailer < ApplicationMailer
  layout 'provider_email_with_footer', except: %i[account_created fallback_sign_in_email]

  def account_created(provider_user)
    @provider_user = provider_user

    notify_email(
      to: @provider_user.email_address,
      subject: t('provider_mailer.account_created.subject'),
    )
  end

  def application_submitted(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_submitted.subject', course_name_and_code: @application.course_name_and_code),
    )
  end

  def application_submitted_with_safeguarding_issues(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_submitted_with_safeguarding_issues.subject', course_name_and_code: @application.course_name_and_code),
    )
  end

  def application_rejected_by_default(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_rejected_by_default.subject', candidate_name: @application.candidate_name, support_reference: @application.support_reference),
    )
  end

  def chase_provider_decision(provider_user, application_choice)
    @application = map_application_choice_params(application_choice)
    @working_days_left = Time.zone.now.to_date.business_days_until(application_choice.reject_by_default_at.to_date)

    email_for_provider(
      provider_user,
      application_choice.application_form,
      subject: I18n.t!('provider_mailer.application_waiting_for_decision.subject', candidate_name: @application.candidate_name, support_reference: @application.support_reference),
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

  def application_withdrawn(provider_user, application_choice)
    @application_choice = application_choice

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

  def ucas_match_initial_email_duplicate_applications(provider_user, application_choice)
    @application_form = application_choice.application_form
    @course_name_and_code = application_choice.course_option.course.name_and_code
    @provider_name = application_choice.course_option.course.provider.name
    @withdraw_by_date = TimeLimitCalculator.new(rule: :ucas_match_candidate_withdrawal_request, effective_date: Time.zone.today).call.fetch(:time_in_future).to_s(:govuk_date)

    email_for_provider(
      provider_user,
      @application_form,
      subject: I18n.t!('provider_mailer.ucas_match.initial_email.duplicate_applications.subject'),
    )
  end

  def fallback_sign_in_email(provider_user, token)
    @token = token

    notify_email(
      to: provider_user.email_address,
      subject: t('authentication.sign_in.email.subject'),
    )
  end

  def ucas_match_resolved_on_ucas_email(provider_user, application_choice)
    @application_form = application_choice.application_form
    @course_name_and_code = application_choice.course.name_and_code

    email_for_provider(
      provider_user,
      @application_form,
      subject: I18n.t!('provider_mailer.ucas_match.resolved.subject'),
    )
  end

  def ucas_match_resolved_on_apply_email(provider_user, application_choice)
    @application_form = application_choice.application_form
    @course_name_and_code = application_choice.course.name_and_code

    email_for_provider(
      provider_user,
      @application_form,
      subject: I18n.t!('provider_mailer.ucas_match.resolved.subject'),
    )
  end

  def courses_open_on_apply(provider_user)
    @current_recruitment_cycle_year = RecruitmentCycle.current_year

    notify_email(to: provider_user.email_address)
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
      :support_reference,
    ).new(
      application_choice.application_form.full_name,
      application_choice.offered_course.name_and_code,
      application_choice.application_form.submitted_at.to_s(:govuk_date).strip,
      application_choice.id,
      application_choice,
      application_choice.reject_by_default_at,
      application_choice.reject_by_default_days,
      application_choice.application_form.support_reference,
    )
  end
end
