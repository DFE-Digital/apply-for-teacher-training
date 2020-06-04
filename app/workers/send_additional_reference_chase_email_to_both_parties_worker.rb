class SendAdditionalReferenceChaseEmailToBothPartiesWorker
  include Sidekiq::Worker

  def perform
    applications_that_need_chasing
    .each do |application_form|
      referees_that_need_chasing = application_form.application_references.select { |reference| reference.feedback_overdue? && reference.requested_at < time_limit }
      referees_that_need_chasing.each do |referee|
        CandidateMailer.chase_reference_again(referee).deliver_later
        RefereeMailer.reference_request_chase_again(referee).deliver_later
      end

      ChaserSent.create!(chased: application_form, chaser_type: :follow_up_missing_references)
    end
  end

private

  def applications_that_need_chasing
    outstanding_reference_requests =
      ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', time_limit])

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
      .having('application_choices.status = ?', :awaiting_references)
  end

  def time_limit
    TimeLimitConfig.additional_reference_chase_calendar_days.days.before(Time.zone.now)
  end
end
