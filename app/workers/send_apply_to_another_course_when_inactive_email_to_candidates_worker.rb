class SendApplyToAnotherCourseWhenInactiveEmailToCandidatesWorker
  include Sidekiq::Worker

  STAGGER_OVER = 20.minutes
  BATCH_SIZE = 150

  def perform
    return if after_apply_deadline?

    GroupedRelationBatchDelivery.new(relation: GetInactiveApplicationsFromPastDay.call, stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, records|
      SendApplyToAnotherCourseWhenInactiveEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end

private

  def after_apply_deadline?
    CycleTimetable.current_date.after? CycleTimetable.apply_deadline
  end
end
