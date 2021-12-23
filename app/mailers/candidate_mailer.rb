class CandidateMailer < ApplicationMailer
  layout 'candidate_email_with_support_footer'

  def application_submitted(application_form)
    @candidate_magic_link = candidate_magic_link(application_form.candidate)
    @application_choice = application_form.application_choices.first
    @reject_by_default_date = @application_choice.reject_by_default_at.to_s(:govuk_date)

    email_for_candidate(
      application_form,
    )
  end

  def application_submitted_apply_again(application_form)
    @application_choice = application_form.application_choices.first
    @reject_by_default_date = @application_choice.reject_by_default_at.to_s(:govuk_date)

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
    @course_name = application_choice.current_course_option.course.name

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.new_interview.subject', provider_name: @provider_name),
    )
  end

  def interview_updated(application_choice, interview)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @course_name = application_choice.current_course_option.course.name

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.interview_updated.subject', provider_name: @provider_name),
    )
  end

  def interview_cancelled(application_choice, interview, reason)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @course_name = application_choice.current_course_option.course.name
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
    @awaiting_decision = application_choice.self_and_siblings.find(&:decision_pending?)
    return if @awaiting_decision.reject_by_default_at.blank?

    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @offer = application_choice.self_and_siblings.find(&:offer?)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)
    @awaiting_decision_by = @awaiting_decision.reject_by_default_at.to_s(:govuk_date)

    email_for_candidate(application_choice.application_form)
  end

  def application_rejected_awaiting_decision_only(application_choice)
    @awaiting_decision = application_choice.self_and_siblings.select(&:decision_pending?)
    reject_by_default_at = @awaiting_decision.sort_by(&:reject_by_default_at).map(&:reject_by_default_at).last
    return if reject_by_default_at.blank?

    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @awaiting_decisions_by = reject_by_default_at.to_s(:govuk_date)

    email_for_candidate(application_choice.application_form)
  end

  def application_rejected_offers_only(application_choice)
    @offers = application_choice.self_and_siblings.select(&:offer?)
    decline_by_default_at = @offers.sort_by(&:decline_by_default_at).map(&:decline_by_default_at).first
    return if decline_by_default_at.blank?

    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @respond_by_date = decline_by_default_at.to_s(:govuk_date)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.application_rejected_offers_only.subject', date: @respond_by_date),
    )
  end

  def application_withdrawn_on_request_all_applications_withdrawn(application_choice)
    @course = application_choice.course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)
    @multiple_applications = application_choice.self_and_siblings.count > 1

    email_for_candidate(application_choice.application_form)
  end

  def application_withdrawn_on_request_one_offer_one_awaiting_decision(application_choice)
    @awaiting_decision = application_choice.self_and_siblings.find(&:decision_pending?)
    return if @awaiting_decision.reject_by_default_at.blank?

    @course = application_choice.course_option.course
    @application_choice = application_choice
    @offer = application_choice.self_and_siblings.find(&:offer?)
    @awaiting_decision_by = @awaiting_decision.reject_by_default_at.to_s(:govuk_date)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    email_for_candidate(application_choice.application_form)
  end

  def application_withdrawn_on_request_awaiting_decision_only(application_choice)
    @awaiting_decision = application_choice.self_and_siblings.select(&:decision_pending?)
    reject_by_default_at = @awaiting_decision.sort_by(&:reject_by_default_at).map(&:reject_by_default_at).last
    return if reject_by_default_at.blank?

    @course = application_choice.course_option.course
    @application_choice = application_choice
    @awaiting_decisions_by = reject_by_default_at.to_s(:govuk_date)

    email_for_candidate(application_choice.application_form)
  end

  def application_withdrawn_on_request_offers_only(application_choice)
    @offers = application_choice.self_and_siblings.select(&:offer?)
    decline_by_default_at = @offers.sort_by(&:decline_by_default_at).map(&:decline_by_default_at).first
    return if decline_by_default_at.blank?

    @course = application_choice.course_option.course
    @application_choice = application_choice
    @respond_by_date = decline_by_default_at.to_s(:govuk_date)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.application_withdrawn_on_request_offers_only.subject', date: @respond_by_date),
    )
  end

  def feedback_received_for_application_rejected_by_default(application_choice, show_apply_again_guidance)
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @course = @application_choice.current_course_option.course
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)
    @show_apply_again_guidance = show_apply_again_guidance

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
    @selected_references = reference.application_form.application_references.select(&:selected)
    @provided_references = reference.application_form.application_references.select(&:feedback_provided?)
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

  def conditions_statuses_changed(application_choice, met_conditions, pending_conditions, previously_met_conditions)
    @application_choice = application_choice
    course = application_choice.current_course_option.course
    @provider_name = course.provider.name
    @course_name_and_code = course.name_and_code

    @met_conditions = met_conditions
    @pending_conditions = pending_conditions
    @previously_met_conditions = previously_met_conditions

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_statuses_changed.subject', provider_name: @provider_name, course_name: @course_name_and_code),
    )
  end

  def conditions_met(application_choice)
    @application_choice = application_choice
    course = application_choice.current_course_option.course
    course_name = "#{course.name_and_code} at #{course.provider.name}"

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_met.subject', course_name: course_name),
    )
  end

  def conditions_not_met(application_choice)
    @application_choice = application_choice
    course = application_choice.current_course_option.course
    course_name = "#{course.name_and_code} at #{course.provider.name}"

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_not_met.subject', course_name: course_name),
    )
  end

  def changed_offer(application_choice)
    @application_choice = application_choice
    @conditions = @application_choice.offer.conditions_text
    @course_option = @application_choice.course_option
    @current_course_option = @application_choice.current_course_option
    @is_awaiting_decision = application_choice.self_and_siblings.decision_pending.any?
    @offers = @application_choice.self_and_siblings.select(&:offer?).map do |choice|
      "#{choice.current_course_option.course.name_and_code} at #{choice.current_course_option.course.provider.name}"
    end

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.changed_offer.subject', provider_name: @course_option.course.provider.name),
    )
  end

  def deferred_offer(application_choice)
    @application_choice = application_choice
    @course = @application_choice.current_course_option.course
    @new_course_academic_year = "#{@course.recruitment_cycle_year + 1} to #{@course.recruitment_cycle_year + 2}"

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.deferred_offer.subject', provider_name: @course.provider.name),
    )
  end

  def deferred_offer_reminder(application_choice)
    @application_choice = application_choice
    @course_option = @application_choice.current_course_option

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.deferred_offer_reminder.subject', provider_name: @course_option.course.provider.name),
    )
  end

  def reinstated_offer(application_choice)
    @application_choice = application_choice
    @course_option = @application_choice.current_course_option
    @conditions = @application_choice.offer.conditions_text

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

  def offer_withdrawn(application_choice)
    @course_name_and_code = application_choice.current_course_option.course.name_and_code
    @provider_name = application_choice.current_course_option.provider.name
    @withdrawal_reason = application_choice.offer_withdrawal_reason
    @candidate_magic_link = candidate_magic_link(application_choice.application_form.candidate)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_withdrawn.subject', provider_name: @provider_name),
    )
  end

  def offer_accepted(application_choice)
    @course_name_and_code = application_choice.current_course_option.course.name_and_code
    @provider_name = application_choice.current_course_option.provider.name
    @start_date = application_choice.current_course_option.course.start_date.to_s(:month_and_year)

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
    @course_name_and_code = application_choice.current_course_option.course.name_and_code
    @provider_name = application_choice.current_course_option.provider.name
    @start_date = application_choice.current_course_option.course.start_date.to_s(:month_and_year)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.unconditional_offer_accepted.subject', {
        course_name_and_code: @course_name_and_code,
        provider_name: @provider_name,
        start_date: @start_date,
      }),
    )
  end

  def eoc_deadline_reminder(application_form)
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.approaching_eoc_deadline.subject'),
    )
  end

  def find_has_opened(application_form)
    @academic_year = CycleTimetable.cycle_year_range(RecruitmentCycle.current_year)
    @apply_opens = CycleTimetable.apply_opens.to_s(:govuk_date)

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.find_has_opened.subject'),
    )
  end

  def new_cycle_has_started(application_form)
    @academic_year = CycleTimetable.cycle_year_range(RecruitmentCycle.current_year)

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.new_cycle_has_started.subject', academic_year: @academic_year),
    )
  end

  def fraud_match_email(application_form)
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.fraud_match.subject'),
    )
  end

private

  def new_offer(application_choice, template_name)
    @application_choice = application_choice
    course_option = CourseOption.find_by(id: @application_choice.current_course_option_id) || @application_choice.course_option
    @provider_name = course_option.course.provider.name
    @course_name = course_option.course.name_and_code
    @conditions = @application_choice.offer.conditions_text
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
