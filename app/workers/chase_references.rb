class ChaseReferences
  include Sidekiq::Worker

  def perform
    send_7_day_chaser!
    send_14_day_chaser!
    send_28_day_chaser!
  end

private

  def send_7_day_chaser!
    GetReferencesToChase.call.each do |reference|
      SendReferenceChaseEmailToRefereeAndCandidate.call(
        application_form: reference.application_form,
        reference: reference,
      )
    end
  end

  def send_14_day_chaser!
    GetRefereesThatNeedReplacing.call.each do |reference|
      SendNewRefereeRequestEmail.call(
        reference: reference,
        reason: :not_responded,
      )
    end
  end

  def send_28_day_chaser!
    applications_that_need_chasing_after_28_days
    .each do |application_form|
      referees_that_need_chasing = application_form.application_references.select { |reference| reference.feedback_overdue? && reference.requested_at < final_chaser_time_limit }
      referees_that_need_chasing.each do |referee|
        CandidateMailer.chase_reference_again(referee).deliver_later
        RefereeMailer.reference_request_chase_again_email(referee).deliver_later
      end

      ChaserSent.create!(chased: application_form, chaser_type: :follow_up_missing_references)
    end
  end

  def applications_that_need_chasing_after_28_days
    outstanding_reference_requests =
      ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', final_chaser_time_limit])

    application_form_ids =
      outstanding_reference_requests
      .where(application_form_id: applications_waiting_on_reference_feedback.pluck(:id))
      .distinct(:application_form_id)
      .pluck(:application_form_id)

    ApplicationForm
      .where(id: application_form_ids)
      .where.not(id: ChaserSent.follow_up_missing_references.select(:chased_id))
  end

  def applications_waiting_on_reference_feedback
    ApplicationForm
      .joins(:application_choices)
      .group('application_forms.id, application_choices.status')
      .having('application_choices.status = ?', :unsubmitted)
  end

  def final_chaser_time_limit
    TimeLimitConfig.additional_reference_chase_calendar_days.days.before(Time.zone.now)
  end
end
