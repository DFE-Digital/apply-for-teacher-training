class CandidateMailer < ApplicationMailer
  helper :view

  def application_submitted(application_form)
    email_for_candidate(application_form)
  end

  def application_sent_to_provider(application_form)
    @application = OpenStruct.new(
      choice_count: application_form.application_choices.count,
      reject_by_default_days: application_form.application_choices.first.reject_by_default_days,
    )

    email_for_candidate(application_form)
  end

  def chase_reference(reference)
    @reference = reference

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!('candidate_mailer.chase_reference.subject', referee_name: reference.name),
    )
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

  def new_referee_request(reference, reason:)
    @reference = reference
    @reason = reason

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!("candidate_mailer.new_referee_request.#{@reason}.subject", referee_name: @reference.name),
    )
  end

  def application_rejected_all_rejected(application_choice)
    application_rejected(application_choice, :all_rejected)
  end

  def application_rejected_awaiting_decisions(application_choice)
    application_rejected(application_choice, :awaiting_decisions)
  end

  def application_rejected_offers_made(application_choice)
    application_rejected(application_choice, :offers_made)
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

  def reference_received(reference)
    @reference = reference

    email_for_candidate(reference.application_form)
  end

private

  def application_rejected(application_choice, template_name)
    decisions = application_choice.application_form.application_choices.select(&:awaiting_provider_decision?).map do |decision|
      "#{decision.course_option.course.name_and_code} at #{decision.course_option.course.provider.name}"
    end
    offers = application_choice.application_form.application_choices.select(&:offer?)
    decline_by_default_at = offers.map(&:decline_by_default_at).compact.max&.to_s(:govuk_date)
    dbd_days = offers.map(&:decline_by_default_days).max

    # We can't use `through:` associations with FactoryBot's `build_stubbed`. Using
    # the association directly instead allows us to use `build_stubbed` in tests
    # and mailer previews.
    course = application_choice.course_option.course

    @application = OpenStruct.new(
      application_choice: application_choice,
      provider_name: course.provider.name,
      course_name: course.name_and_code,
      rejection_reason: application_choice.rejection_reason,
      candidate_name: application_choice.application_form.first_name,
      choice_count: application_choice.application_form.application_choices.count,
      decisions: decisions,
      decline_by_default_at: decline_by_default_at,
      offers: offers,
      dbd_days: dbd_days,
    )

    view_mail(
      GENERIC_NOTIFY_TEMPLATE,
      to: application_choice.application_form.candidate.email_address,
      subject: t("application_choice_rejected_email.subject.#{template_name}",
                 provider_name: course.provider.name,
                 course_name: course.name_and_code,
                 dbd_days: dbd_days),
      template_path: 'candidate_mailer/application_rejected',
      template_name: template_name,
      )
  end

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

  def email_for_candidate(application_form, args = {})
    @application_form = application_form
    @candidate = @application_form.candidate

    view_mail(
      GENERIC_NOTIFY_TEMPLATE,
      to: @candidate.email_address,
      subject: args[:subject] || I18n.t!("candidate_mailer.#{action_name}.subject"),
    )
  end
end
