class SendAdditionalReferenceChaseEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    applications_with_outstanding_reference_requests.each do |application_form|
      CandidateMailer.chase_references_again(application_form).deliver_later
      ChaserSent.create!(chased: application_form, chaser_type: :follow_up_missing_references)
    end
  end

private

  def applications_with_outstanding_reference_requests
    outstanding_reference_requests = ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', time_limit])

    application_form_ids = outstanding_reference_requests
      .distinct(:application_form_id)
      .pluck(:application_form_id)

    ApplicationForm
      .where(id: application_form_ids)
      .where.not(id: ChaserSent.follow_up_missing_references.select(:chased_id))
  end

  def time_limit
    TimeLimitConfig.additional_reference_chase_calendar_days.days.before(Time.zone.now)
  end
end
