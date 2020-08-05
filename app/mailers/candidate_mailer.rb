class CandidateMailer < ApplicationMailer
  def application_submitted(application_form)
    @candidate_magic_link = candidate_magic_link(application_form.candidate)
    @respond_within_days = TimeLimitCalculator.new(
      rule: :reject_by_default,
      effective_date: application_form.application_choices.first&.sent_to_provider_at || Time.zone.now,
    ).call[:days]

    email_for_candidate(
      application_form,
    )
  end

  def application_submitted_apply_again(application_form)
    @application_choice = application_form.application_choices.first

    email_for_candidate(
      application_form,
    )
  end

  def application_sent_to_provider(application_form)
    email_for_candidate(
      application_form,
    )
  end

  def chase_reference(reference)
    @reference = reference

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!('candidate_mailer.chase_reference.subject', referee_name: reference.name),
    )
  end

  def chase_reference_again(referee)
    @referee = referee

    email_for_candidate(
      referee.application_form,
      subject: I18n.t!('candidate_mailer.chase_reference_again.subject', referee_name: @referee.name),
    )
  end

  def survey_email(application_form)
    email_for_candidate(
      application_form,
    )
  end

  def survey_chaser_email(application_form)
    email_for_candidate(
      application_form,
    )
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
    @course = application_choice.course_option.course
    @application_choice = application_choice
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    template_name = :application_rejected_all_rejected_apply_again

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!(
        application_choice.rejected_by_default ? "candidate_mailer.application_rejected_by_default.subject" : "candidate_mailer.application_rejected.all_rejected.subject",
        provider_name: @course.provider.name,
      ),
      template_name: template_name,
    )
  end

  def application_rejected_awaiting_decisions(application_choice)
    @decisions = application_choice.application_form.application_choices.select(&:awaiting_provider_decision?)
    @application_choice = application_choice

    # We can't use `through:` associations with FactoryBot's `build_stubbed`. Using
    # the association directly instead allows us to use `build_stubbed` in tests
    # and mailer previews.
    @course = application_choice.course_option.course

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!(
        "candidate_mailer.application_rejected#{application_choice.rejected_by_default ? '_by_default' : ''}.awaiting_decisions.subject",
        provider_name: @course.provider.name,
        course_name: @course.name_and_code,
      ),
    )
  end

  def application_rejected_offers_made(application_choice)
    @offers = application_choice.application_form.application_choices.select(&:offer?)
    @decline_by_default_at = @offers.first.decline_by_default_at.to_s(:govuk_date)
    @dbd_days = @offers.first.decline_by_default_days
    @application_choice = application_choice

    # We can't use `through:` associations with FactoryBot's `build_stubbed`. Using
    # the association directly instead allows us to use `build_stubbed` in tests
    # and mailer previews.
    @course = application_choice.course_option.course

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!(
        "candidate_mailer.application_rejected#{application_choice.rejected_by_default ? '_by_default' : ''}.offers_made.subject",
        provider_name: @course.provider.name,
        dbd_days: @dbd_days,
      ),
    )
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

    email_for_candidate(
      reference.application_form,
    )
  end

  def chase_candidate_decision(application_form)
    @application_choices = application_form.application_choices.select(&:offer?)
    @dbd_date = @application_choices.first.decline_by_default_at.to_s(:govuk_date).strip
    @days_until_chaser = TimeLimitCalculator.new(rule: :chase_candidate_before_dbd, effective_date: @application_choices.first.sent_to_provider_at).call.fetch(:days)

    subject_pluralisation = @application_choices.count > 1 ? 'plural' : 'singular'

    email_for_candidate(
      application_form,
      subject: I18n.t!("chase_candidate_decision_email.subject_#{subject_pluralisation}"),
    )
  end

  def declined_by_default(application_form)
    @declined_courses = application_form.application_choices.select(&:declined_by_default?)
    @declined_course_names = @declined_courses.map { |application_choice| "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}" }

    if application_form.ended_without_success? && application_form.application_choices.select(&:rejected?).present?
      template_name = :declined_by_default_with_rejections
      subject = I18n.t!('candidate_mailer.decline_by_default_last_course_choice.subject', count: @declined_courses.size)
    elsif application_form.ended_without_success?
      template_name = :declined_by_default_without_rejections
      subject = I18n.t!('candidate_mailer.decline_by_default_last_course_choice.subject', count: @declined_courses.size)
    else
      template_name = :declined_by_default
      subject = I18n.t!('candidate_mailer.declined_by_default.subject', count: @declined_courses.size)
    end

    email_for_candidate(
      application_form,
      subject: subject,
      template_name: template_name,
    )
  end

  def conditions_met(application_choice)
    @application_choice = application_choice
    course = application_choice.course_option.course
    course_name = "#{course.name_and_code} at #{course.provider.name}"

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_met.subject', course_name: course_name),
    )
  end

  def conditions_not_met(application_choice)
    @application_choice = application_choice
    course = application_choice.course_option.course
    course_name = "#{course.name_and_code} at #{course.provider.name}"

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_not_met.subject', course_name: course_name),
    )
  end

  def changed_offer(application_choice)
    @application_choice = application_choice
    @course_option = @application_choice.course_option

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.changed_offer.subject', provider_name: @course_option.course.provider.name),
    )
  end

  def withdraw_last_application_choice(application_form)
    @withdrawn_courses = application_form.application_choices.select(&:withdrawn?)
    @withdrawn_course_names = @withdrawn_courses.map { |application_choice| "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}" }
    @rejected_course_choices_count = application_form.application_choices.select(&:rejected?).count

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.application_withdrawn.subject', count: @withdrawn_courses.size),
    )
  end

  def decline_last_application_choice(application_choice)
    @declined_course = application_choice
    @declined_course_name = "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}"
    @rejected_course_choices_count = application_choice.application_form.application_choices.select(&:rejected?).count

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.application_declined.subject'),
    )
  end

  def apply_again_call_to_action(application_form)
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.apply_again_call_to_action.subject'),
    )
  end

  def course_unavailable_notification(application_choice, reason)
    @application_choice = application_choice
    @application_form = application_choice.application_form
    email_for_candidate(
      @application_form,
      subject: I18n.t!(
        "candidate_mailer.course_unavailable_notification.subject.#{reason}",
        course_name: application_choice.course_option.course.name_and_code,
        provider_name: application_choice.course_option.course.provider.name,
        study_mode: application_choice.course_option.study_mode.humanize.downcase,
      ),
      template_name: "course_unavailable_#{reason}",
    )
  end

private

  def new_offer(application_choice, template_name)
    @application_choice = application_choice
    @provider_name = @application_choice.course_option.course.provider.name
    @course_name = @application_choice.course_option.course.name_and_code
    @conditions = @application_choice.offer&.dig('conditions') || []
    @offers = @application_choice.application_form.application_choices.select(&:offer?).map do |offer|
      "#{offer.course_option.course.name_and_code} at #{offer.course_option.course.provider.name}"
    end

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!(
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

    mailer_options = {
      to: @candidate.email_address,
      subject: args.delete(:subject) || I18n.t!("candidate_mailer.#{action_name}.subject"),
      application_form_id: application_form.id,
    }.merge(args)

    notify_email(mailer_options)
  end

  def candidate_magic_link(candidate)
    raw_token = candidate.refresh_magic_link_token!
    candidate_interface_authenticate_url(u: candidate.encrypted_id, token: raw_token)
  end
  helper_method :candidate_magic_link
end
