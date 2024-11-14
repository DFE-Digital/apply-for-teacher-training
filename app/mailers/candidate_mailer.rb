class CandidateMailer < ApplicationMailer
  helper UtmLinkHelper
  include QualificationValueHelper

  def application_choice_submitted(application_choice)
    @application_choice = application_choice
    @candidate_magic_link = candidate_magic_link(application_choice.application_form.candidate)

    email_for_candidate(
      application_choice.application_form,
    )
  end

  def chase_reference(reference)
    @reference = reference
    @provider_name = reference.provider_name
    @application_form = @reference.application_form

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!('candidate_mailer.chase_reference.subject', referee_name: reference.name),
    )
  end

  def chase_reference_again(referee)
    @referee = referee
    @provider_name = referee.provider_name

    email_for_candidate(
      referee.application_form,
      subject: I18n.t!('candidate_mailer.chase_reference_again.subject', referee_name: @referee.name),
    )
  end

  def new_referee_request(reference, reason:)
    @reference = reference
    @reason = reason
    @provider_name = reference.provider_name

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!("candidate_mailer.new_referee_request.#{@reason}.subject", referee_name: @reference.name),
    )
  end

  def new_interview(application_choice, interview)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @course_name_and_code = application_choice.current_course_option.course.name_and_code

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.new_interview.subject', course_name_and_code: @course_name_and_code),
    )
  end

  def interview_updated(application_choice, interview, previous_course = nil)
    @application_form = application_choice.application_form
    @interview = interview
    @provider_name = interview.provider.name
    @current_course_name_and_code = application_choice.current_course_option.course.name_and_code
    @previous_course_name_and_code = previous_course&.name_and_code
    @updated_course_name_and_code =  @current_course_name_and_code if @previous_course_name_and_code.present?

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.interview_updated.subject', course_name_and_code: @previous_course_name_and_code || @updated_course_name_and_code),
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

  def application_rejected(application_choice)
    @course = application_choice.current_course_option.course
    @application_choice = RejectedApplicationChoicePresenter.new(application_choice)
    @candidate_magic_link = candidate_magic_link(@application_choice.application_form.candidate)

    email_for_candidate(application_choice.application_form)
  end

  def application_withdrawn_on_request(application_choice)
    @course = application_choice.current_course_option.course
    @provider_name = @course.provider.name
    @course_name_and_code = application_choice.current_course_option.course.name_and_code
    @application_form = application_choice.application_form
    email_for_candidate(@application_form)
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

  def new_offer_made(application_choice)
    @application_choice = application_choice
    @course = @application_choice.current_course_option.course
    @provider_name = @course.provider.name
    @course_name_and_code = @application_choice.current_course_option.course.name_and_code
    @application_form = @application_choice.application_form
    @show_deadline_reminder = (CycleTimetable.decline_by_default_date - 4.weeks).before? Time.zone.now
    email_for_candidate(@application_form, subject: I18n.t('candidate_mailer.new_offer_made.subject', provider_name: @course.provider.name))
  end

  def reference_received(reference)
    @reference = reference
    @selected_references = reference.application_form.application_references.creation_order.select(&:selected)
    @provided_references = reference.application_form.application_references.creation_order.select(&:feedback_provided?)

    email_for_candidate(
      reference.application_form,
      subject: I18n.t!('candidate_mailer.reference_received.subject', referee_name: @reference.name),
    )
  end

  def offer_10_day(application_choice)
    @first_name = application_choice.application_form.first_name
    @course_name = application_choice.current_course_option.course.name
    @candidate = application_choice.application_form.candidate
    @provider_name = application_choice.current_course_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_day.subject', provider_name: @provider_name),
    )
  end

  def offer_20_day(application_choice)
    @first_name = application_choice.application_form.first_name
    @course_name = application_choice.current_course_option.course.name
    @candidate = application_choice.application_form.candidate
    @provider_name = application_choice.current_course_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_day.subject', provider_name: @provider_name),
    )
  end

  def offer_30_day(application_choice)
    @first_name = application_choice.application_form.first_name
    @course_name = application_choice.current_course_option.course.name
    @candidate = application_choice.application_form.candidate
    @provider_name = application_choice.current_course_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_day.subject', provider_name: @provider_name),
    )
  end

  def offer_40_day(application_choice)
    @first_name = application_choice.application_form.first_name
    @course_name = application_choice.current_course_option.course.name
    @candidate = application_choice.application_form.candidate
    @provider_name = application_choice.current_course_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_day.subject', provider_name: @provider_name),
    )
  end

  def offer_50_day(application_choice)
    @first_name = application_choice.application_form.first_name
    @course_name = application_choice.current_course_option.course.name
    @candidate = application_choice.application_form.candidate
    @provider_name = application_choice.current_course_option.provider.name

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_50_day.subject', provider_name: @provider_name),
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
    @course = application_choice.current_course_option.course
    @start_date = application_choice.current_course_option.course.start_date.to_fs(:month_and_year)

    course_name = "#{@course.name_and_code} at #{@course.provider.name}"
    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_met.subject', course_name:),
    )
  end

  def conditions_not_met(application_choice)
    @application_choice = application_choice
    course = application_choice.current_course_option.course
    course_name = "#{course.name_and_code} at #{course.provider.name}"

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.conditions_not_met.subject', course_name:),
    )
  end

  def changed_offer(application_choice)
    @application_choice = application_choice
    @conditions = @application_choice.offer.all_conditions_text
    @course_option = @application_choice.course_option
    @current_course_option = @application_choice.current_course_option
    @qualification = qualification_text(@current_course_option)

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.changed_offer.subject', course_details: @course_option.course.name_and_code),
    )
  end

  def change_course(application_choice, old_course)
    @application_choice = application_choice
    @course_option = old_course
    @current_course_option = @application_choice.current_course_option
    @qualification = qualification_text(@current_course_option)

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!(
        'candidate_mailer.course_change.subject',
        course_details: @course_option.course.name_and_code,
      ),
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
    @provider_name = @course_option.provider.name
    @course_name = @course_option.course.name_and_code
    @conditions = @application_choice.offer.all_conditions_text

    email_for_candidate(
      @application_choice.application_form,
      subject: I18n.t!('candidate_mailer.reinstated_offer.subject', provider_name: @provider_name, course_name: @course_name),
    )
  end

  def withdraw_last_application_choice(application_form)
    @withdrawn_courses = application_form.application_choices.select(&:withdrawn?)
    @withdrawn_course_names = @withdrawn_courses.map { |application_choice| "#{application_choice.current_course_option.course.name_and_code} at #{application_choice.current_course_option.course.provider.name}" }
    @rejected_course_choices_count = application_form.application_choices.select(&:rejected?).count
    @candidate_magic_link = candidate_magic_link(application_form.candidate)

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.application_withdrawn.subject', count: @withdrawn_courses.size),
    )
  end

  def decline_last_application_choice(application_choice)
    @declined_course = application_choice
    @declined_course_name = "#{application_choice.current_course_option.course.name_and_code} at #{application_choice.current_course_option.course.provider.name}"
    @rejected_course_choices_count = application_choice.self_and_siblings.select(&:rejected?).count
    @candidate_magic_link = candidate_magic_link(application_choice.application_form.candidate)

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.application_declined.subject'),
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
    @start_date = application_choice.current_course_option.course.start_date.to_fs(:month_and_year)

    kwargs = {
      course_name_and_code: @course_name_and_code,
      provider_name: @provider_name,
    }

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.offer_accepted.subject', **kwargs),
    )
  end

  def unconditional_offer_accepted(application_choice)
    @course_name_and_code = application_choice.current_course_option.course.name_and_code
    @provider_name = application_choice.current_course_option.provider.name
    @start_date = application_choice.current_course_option.course.start_date.to_fs(:month_and_year)

    kwargs = {
      course_name_and_code: @course_name_and_code,
      provider_name: @provider_name,
      start_date: @start_date,
    }

    email_for_candidate(
      application_choice.application_form,
      subject: I18n.t!('candidate_mailer.unconditional_offer_accepted.subject', **kwargs),
    )
  end

  def eoc_first_deadline_reminder(application_form)
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.approaching_eoc_deadline.subject'),
    )
  end

  def eoc_second_deadline_reminder(application_form)
    apply_deadline = I18n.l(CycleTimetable.apply_deadline.to_date, format: :no_year)
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.approaching_eoc_second_deadline_reminder.subject', apply_deadline:),
    )
  end

  def application_deadline_has_passed(application_form)
    year = application_form.recruitment_cycle_year
    @this_academic_year = CycleTimetable.cycle_year_range(year)
    @next_academic_year = CycleTimetable.cycle_year_range(year + 1)
    @apply_reopens_date = CycleTimetable.apply_reopens.to_fs(:govuk_date)

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.application_deadline_has_passed.subject'),
    )
  end

  def respond_to_offer_before_deadline(application_form)
    @decline_by_default_deadline = CycleTimetable.decline_by_default_date.to_fs(:govuk_date)
    year = application_form.recruitment_cycle_year
    @this_academic_year = CycleTimetable.cycle_year_range(year)
    @next_academic_year = CycleTimetable.cycle_year_range(year + 1)
    @apply_reopens_date = CycleTimetable.apply_reopens.to_fs(:govuk_date)
    email_for_candidate(
      application_form,
      subject: I18n.t!(
        'candidate_mailer.respond_to_offer_before_deadline.subject',
        decline_by_default_date: @decline_by_default_deadline,
      ),
    )
  end

  def reject_by_default_explainer(application_form)
    year = application_form.recruitment_cycle_year
    @this_academic_year = CycleTimetable.cycle_year_range(year)
    @next_academic_year = CycleTimetable.cycle_year_range(year + 1)
    @apply_reopens_date = CycleTimetable.apply_reopens.to_fs(:govuk_date)

    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.reject_by_default_explainer.subject'),
    )
  end

  def find_has_opened(application_form)
    @academic_year = CycleTimetable.cycle_year_range(RecruitmentCycle.current_year)
    @apply_opens = CycleTimetable.apply_opens.to_fs(:govuk_date)

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

  def duplicate_match_email(application_form)
    @application_form = application_form
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.duplicate_match.subject'),
    )
  end

  def nudge_unsubmitted(application_form)
    @application_form = application_form
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.nudge_unsubmitted.subject'),
      layout: false,
    )
  end

  def nudge_unsubmitted_with_incomplete_references(application_form)
    @application_form = application_form
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_references.no_references.subject'),
      layout: false,
      template_path: 'candidate_mailer/nudge_unsubmitted_with_incomplete_references',
      template_name: :no_references,
    )
  end

  def nudge_unsubmitted_with_incomplete_courses(application_form)
    @application_form = application_form
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_courses.subject'),
      layout: false,
    )
  end

  def nudge_unsubmitted_with_incomplete_personal_statement(application_form)
    @application_form = application_form
    email_for_candidate(
      application_form,
      subject: I18n.t!('candidate_mailer.nudge_unsubmitted_with_incomplete_personal_statement.subject'),
      layout: false,
    )
  end

  def apply_to_another_course_after_30_working_days(application_form)
    @application_form = application_form
    application_choice = application_form.application_choices.inactive_past_day&.first

    return unless application_choice

    course = application_choice.current_course_option.course
    @provider_name = course.provider.name
    @course_name_and_code = course.name_and_code

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.apply_to_course_after_inactivity.subject'),
      layout: false,
    )
  end

  def apply_to_multiple_courses_after_30_working_days(application_form)
    @application_form = application_form
    application_choices = application_form.application_choices.inactive_past_day

    return unless application_choices.many?

    @applications = application_choices.map do |application_choice|
      {
        course_name_and_code: application_choice.current_course_option.course.name_and_code,
        provider_name: application_choice.current_course_option.course.provider.name,
      }
    end

    @choices_remaining = application_form.number_of_slots_left
    @submitted_at = application_choices.first.sent_to_provider_at.to_date.to_fs(:govuk_date)

    email_for_candidate(
      @application_form,
      subject: I18n.t!('candidate_mailer.apply_to_course_after_inactivity.subject'),
      layout: false,
    )
  end

private

  def email_for_candidate(application_form, args = {})
    @application_form = application_form
    @candidate = @application_form.candidate

    mailer_options = {
      to: @candidate.email_address,
      subject: args.delete(:subject) || I18n.t!("candidate_mailer.#{action_name}.subject"),
      application_form_id: application_form.id,
      reference: uid,
    }.merge(args)

    notify_email(mailer_options)
  end

  def candidate_magic_link(candidate)
    raw_token = candidate.create_magic_link_token!
    candidate_interface_authenticate_url({ token: raw_token }.merge(utm_args))
  end

  def candidate_realistic_job_preview_link(candidate)
    realistic_job_preview_url({ id: candidate.pseudonymised_id }.merge(utm_args))
  end

  def candidate_unsubscribe_link(candidate)
    token = candidate.generate_token_for :unsubscribe_link
    candidate_interface_unsubscribe_from_emails_url(token:)
  end

  helper_method :candidate_magic_link, :candidate_realistic_job_preview_link, :candidate_unsubscribe_link

  def uid
    @uid ||= EmailLogInterceptor.generate_reference
  end

  def utm_args
    { utm_source: uid }
  end
end
