class CandidateMailer < ApplicationMailer
  helper :view

  def submit_application_email(application_form)
    @application_form = application_form
    @candidate = @application_form.candidate

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: @candidate.email_address,
              subject: t('submit_application_success.email.subject'))
  end

  def application_under_consideration(application_form)
    @application = OpenStruct.new(
      candidate: application_form.candidate,
      candidate_name: application_form.first_name,
      choice_count: application_form.application_choices.count,
      rbd_days: application_form.application_choices.first.reject_by_default_days,
    )

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('application_under_consideration.email.subject'))
  end

  def reference_chaser_email(application_form, reference)
    @candidate_name = application_form.first_name
    @referee_name = reference.name
    @referee_email = reference.email_address

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('candidate_reference.subject.chaser', referee_name: @referee_name))
  end

  def survey_email(application_form)
    @name = application_form.first_name
    @thank_you_message = t('survey_emails.thank_you.candidate')

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('survey_emails.subject.initial'),
              template_path: 'survey_emails',
              template_name: 'initial')
  end

  def survey_chaser_email(application_form)
    @name = application_form.first_name

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('survey_emails.subject.chaser'),
              template_path: 'survey_emails',
              template_name: 'chaser')
  end

  def new_referee_request(application_form, reference, reason: :not_responded)
    @candidate = application_form.candidate
    @candidate_name = application_form.first_name
    @referee = reference
    @reason = reason

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t("new_referee_request.#{@reason}.subject", referee_name: @referee.name))
  end

  def new_offer_single_offer(application_choice)
    new_offer(application_choice, :single_offer)
  end

  def new_offer_multiple_offers(application_choice)
    new_offer(application_choice, :multiple_offers)
  end

  def new_offer_decisions_pending(application_choice)
    new_offer(application_choice, :decisions_pending)
  end

private

  def new_offer(application_choice, template_name)
    @application_choice = application_choice
    @candidate_name = @application_choice.application_form.first_name
    @provider_name = @application_choice.course_option.course.provider.name
    @course_name = @application_choice.course_option.course.name_and_code
    @conditions = @application_choice.offer&.dig('conditions') || []
    @offers = @application_choice.application_form.application_choices.select(&:offer?).map do |offer|
      "#{offer.course_option.course.name_and_code} at #{offer.course_option.course.provider.name}"
    end

    view_mail(
      GENERIC_NOTIFY_TEMPLATE,
      to: application_choice.application_form.candidate.email_address,
      subject: t(
        "candidate_offer.#{template_name}.subject",
        course_name: application_choice.course_option.course.name_and_code,
        provider_name: application_choice.course_option.course.provider.name,
      ),
      template_path: 'candidate_mailer/new_offer',
      template_name: template_name,
    )
  end
end
