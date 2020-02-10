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
    @candidate_name = application_form.first_name
    @referee = reference
    @reason = reason

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t("new_referee_request.#{@reason}.subject", referee_name: @referee.name))
  end

  def new_offer(application_choice)
    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_choice.application_form.candidate.email_address,
              subject: t(
                "candidate_offer.#{new_offer_template_name(application_choice)}.subject",
                course_name: application_choice.course_option.course.name_and_code,
                provider_name: application_choice.course_option.course.provider.name,
              ),
              template_path: 'candidate_mailer/new_offer',
              template_name: new_offer_template_name(application_choice))
  end

private

  # TODO: work out whether the are multiple/single offers etc.
  def new_offer_template_name(_application_choice)
    # candidate_application_choices = application_choice.application_form.application_choices
    # number_of_pending_decisions = candidate_application_choices.select(&:awaiting_provider_decision?).count
    # number_of_offers = candidate_application_choices.select(&:offer?).count

    :single_offer
    # if number_of_pending_decisions.positive?
    #   :decisions_pending
    # elsif number_of_offers > 1
    #   :multiple_offers
    # else
    #   :single_offer
    # end
  end
end
