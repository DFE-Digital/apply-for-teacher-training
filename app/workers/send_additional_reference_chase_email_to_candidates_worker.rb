class SendAdditionalReferenceChaseEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    references_to_chase.each do |reference|
      CandidateMailer.chase_reference_again(reference).deliver_later
      ChaserSent.create!(chased: reference, chaser_type: :additional_reference_request)
    end
  end

private

  def references_to_chase
    ApplicationReference
      .feedback_requested
      .where(['requested_at < ?', time_limit])
      .where.not(id: ChaserSent.additional_reference_request.select(:chased_id))
  end

  def time_limit
    TimeLimitConfig.additional_reference_chase_calendar_days.days.before(Time.zone.now)
  end
end
