class CandidateMailer < ApplicationMailer
  layout 'candidate_email_with_support_footer'

  def application_submitted(application_form)
    @candidate_magic_link = candidate_magic_link(application_form.candidate)

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

  def new_referee_request(reference, reason:)
    @reference = reference
    @reason = reason

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!("candidate_mailer.new_referee_request.#{@reason}.subject", referee_name: @reference.name),
    )
  end

  def new_interview(application_choice, interview)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @course_name = application_choice.offered_option.course.name

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.new_interview.subject', provider_name: @provider_name),
    )
  end

  def interview_updated(application_choice, interview)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @course_name = application_choice.offered_option.course.name

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.interview_updated.subject', provider_name: @provider_name),
    )
  end

  def interview_cancelled(application_choice, interview, reason)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @course_name = application_choice.offered_option.course.name
    @reason = reason

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.interview_cancelled.subject', provider_name: @provider_name),
    )
  end

  def application_rejected_all_applications_rejected(application_choice)
    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)
    @multiple_applications = application_choice.self_and_siblings.count > 1

    email_for_candidate(application_choice.application_form)
  end

  def application_rejected_one_offer_one_awaiting_decision(application_choice)
    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @offer = application_choice.self_and_siblings.find(&:offer?)
    @awaiting_decision = application_choice.self_and_siblings.find(&:awaiting_provider_decision?)
    @awaiting_decision_by = @awaiting_decision.reject_by_default_at.to_s(:govuk_date)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    email_for_candidate(application_choice.application_form)
  end

  def application_rejected_awaiting_decision_only(application_choice)
    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @awaiting_decision = application_choice.self_and_siblings.select(&:awaiting_provider_decision?)
    @awaiting_decisions_by = @awaiting_decision.sort_by(&:reject_by_default_at).map(&:reject_by_default_at).last.to_s(:govuk_date)

    email_for_candidate(application_choice.application_form)
  end

  def application_rejected_offers_only(application_choice)
    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @offers = application_choice.self_and_siblings.select(&:offer?)
    @respond_by_date = @offers.sort_by(&:decline_by_default_at).map(&:decline_by_default_at).first.to_s(:govuk_date)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.application_rejected_offers_only.subject', date: @respond_by_date),
    )
  end

  def feedback_received_for_application_rejected_by_default(application_choice)
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @course = @application_choice.offered_option.course

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.feedback_received_for_application_rejected_by_default.subject', provider_name: @course.provider.name),
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
      subject: I18n.t!('candidate_mailer.reference_received.subject', referee_name: @reference.name),
    )
  end

  def chase_candidate_decision(application_form)
    @application_choices = application_form.application_choices.select(&:offer?)
    @dbd_date = @application_choices.first.decline_by_default_at.to_s(:govuk_date).strip
    @days_until_chaser = TimeLimitCalculator.new(rule: :chase_candidate_before_dbd, effective_date: @application_choices.first.sent_to_provider_at).call.fetch(:days)
    @offers = @application_choices.map do |offer|
      "#{offer.course_option.course.name_and_code} at #{offer.course_option.course.provider.name}"
    end
    subject_pluralisation = @application_choices.count > 1 ? 'plural' : 'singular'

    email_for_candidate(
      application_form,
      subject: I18n.t!("candidate_mailer.chase_candidate_decision.subject_#{subject_pluralisation}"),
    )
  end

  def declined_by_default(application_form)
    @declined_courses = application_form.application_choices.select(&:declined_by_default?)
    @declined_course_names = @declined_courses.map { |application_choice| "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}" }
    @candidate_magic_link = candidate_magic_link(application_form.candidate)

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
    @offered_course_option = @application_choice.offered_course_option
    @is_awaiting_decision = application_choice.self_and_siblings.any?(&:awaiting_provider_decision?)
    @offers = @application_choice.self_and_siblings.select(&:offer?).map do |offer|
      "#{offer.course_option.course.name_and_code} at #{offer.course_option.course.provider.name}"
    end

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.changed_offer.subject', provider_name: @course_option.course.provider.name),
    )
  end

  def deferred_offer(application_choice)
    @application_choice = application_choice
    @course = @application_choice.offered_option.course
    @new_course_academic_year = "#{@course.recruitment_cycle_year + 1} to #{@course.recruitment_cycle_year + 2}"

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.deferred_offer.subject', provider_name: @course.provider.name),
    )
  end

  def deferred_offer_reminder(application_choice)
    @application_choice = application_choice
    @course_option = @application_choice.offered_option

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.deferred_offer_reminder.subject', provider_name: @course_option.course.provider.name),
    )
  end

  def reinstated_offer(application_choice)
    @application_choice = application_choice
    @course_option = @application_choice.offered_option
    @conditions = @application_choice.offer&.dig('conditions') || []

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.reinstated_offer.subject'),
    )
  end

  def withdraw_last_application_choice(application_form)
    @withdrawn_courses = application_form.application_choices.select(&:withdrawn?)
    @withdrawn_course_names = @withdrawn_courses.map { |application_choice| "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}" }
    @rejected_course_choices_count = application_form.application_choices.select(&:rejected?).count
    @candidate_magic_link = candidate_magic_link(application_form.candidate)

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.application_withdrawn.subject', count: @withdrawn_courses.size),
    )
  end

  def decline_last_application_choice(application_choice)
    @declined_course = application_choice
    @declined_course_name = "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}"
    @rejected_course_choices_count = application_choice.self_and_siblings.select(&:rejected?).count
    @candidate_magic_link = candidate_magic_link(application_choice.application_form.candidate)

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
    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!(
        "candidate_mailer.course_unavailable_notification.subject.#{reason}",
        course_name: application_choice.course_option.course.name_and_code,
        provider_name: application_choice.course_option.course.provider.name,
        study_mode: application_choice.course_option.study_mode.humanize.downcase,
      ),
      template_name: "course_unavailable_#{reason}",
    )
  end

  def offer_accepted(application_choice)
    @course_name_and_code = application_choice.offered_option.course.name_and_code
    @provider_name = application_choice.offered_option.provider.name
    @start_date = application_choice.offered_option.course.start_date.to_s(:month_and_year)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_accepted.subject', {
        course_name_and_code: @course_name_and_code,
        provider_name: @provider_name,
        start_date: @start_date,
      }),
    )
  end

  def unconditional_offer_accepted(application_choice)
    @course_name_and_code = application_choice.offered_option.course.name_and_code
    @provider_name = application_choice.offered_option.provider.name
    @start_date = application_choice.offered_option.course.start_date.to_s(:month_and_year)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.unconditional_offer_accepted.subject', {
        course_name_and_code: @course_name_and_code,
        provider_name: @provider_name,
        start_date: @start_date,
      }),
    )
  end

  def ucas_match_initial_email_duplicate_applications(application_choice)
    @course_name_and_code = application_choice.course_option.course.name_and_code
    @provider_name = application_choice.course_option.course.provider.name
    @withdraw_by_date = TimeLimitCalculator.new(rule: :ucas_match_candidate_withdrawal_request, effective_date: Time.zone.today).call.fetch(:time_in_future).to_s(:govuk_date)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.ucas_match.duplicate_applications.subject', withdraw_by_date: @withdraw_by_date),
    )
  end

  def ucas_match_initial_email_multiple_acceptances(candidate)
    @withdraw_by_date = TimeLimitCalculator.new(rule: :ucas_match_candidate_withdrawal_request, effective_date: Time.zone.today).call.fetch(:time_in_future).to_s(:govuk_date)

    email_for_candidate(
      candidate.current_application,
      subject: I18n.t!('candidate_mailer.ucas_match.multiple_acceptances.subject', withdraw_by_date: @withdraw_by_date),
    )
  end

  def ucas_match_reminder_email_duplicate_applications(application_choice, ucas_match)
    @course_name_and_code = application_choice.course_option.course.name_and_code
    @provider_name = application_choice.course_option.course.provider.name
    @withdraw_by_date = ucas_match.calculate_action_date(:ucas_match_ucas_withdrawal_request, Time.zone.today).to_s(:govuk_date)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.ucas_match.duplicate_applications.subject', withdraw_by_date: @withdraw_by_date),
    )
  end

  def ucas_match_reminder_email_multiple_acceptances(ucas_match)
    @initial_email_date = ucas_match.candidate_last_contacted_at.to_s(:govuk_date)
    @withdraw_by_date = ucas_match.calculate_action_date(:ucas_match_ucas_withdrawal_request, Time.zone.today).to_s(:govuk_date)

    email_for_candidate(
      ucas_match.candidate.current_application,
      subject: I18n.t!('candidate_mailer.ucas_match.multiple_acceptances.subject', withdraw_by_date: @withdraw_by_date),
    )
  end

  def ucas_match_resolved_on_ucas_email(application_choice)
    @course_name_and_code = application_choice.offered_option.course.name_and_code
    @provider_name = application_choice.offered_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.ucas_match.resolved.subject'),
    )
  end

  def ucas_match_resolved_on_ucas_at_our_request_email(application_choice)
    @course_name_and_code = application_choice.offered_option.course.name_and_code
    @provider_name = application_choice.offered_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.ucas_match.resolved_on_ucas_at_our_request.subject'),
    )
  end

  def ucas_match_resolved_on_apply_email(application_choice)
    @course_name_and_code = application_choice.offered_option.course.name_and_code
    @provider_name = application_choice.offered_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.ucas_match.resolved.subject'),
    )
  end

private

  def new_offer(application_choice, template_name)
    @application_choice = application_choice
    course_option = CourseOption.find_by(id: @application_choice.offered_course_option_id) || @application_choice.course_option
    @provider_name = course_option.course.provider.name
    @course_name = course_option.course.name_and_code
    @conditions = @application_choice.offer&.dig('conditions') || []
    @offers = @application_choice.self_and_siblings.select(&:offer?).map do |offer|
      "#{offer.course_option.course.name_and_code} at #{offer.course_option.course.provider.name}"
    end
    @start_date = course_option.course.start_date.to_s(:month_and_year)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!(
        "candidate_mailer.candidate_offer.#{template_name}.subject",
        course_name: course_option.course.name_and_code,
        provider_name: course_option.course.provider.name,
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
    raw_token = candidate.create_magic_link_token!
    candidate_interface_authenticate_url(token: raw_token)
  end

  helper_method :candidate_magic_link
end
