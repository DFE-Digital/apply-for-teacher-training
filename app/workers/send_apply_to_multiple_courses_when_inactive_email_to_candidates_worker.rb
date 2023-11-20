class SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesWorker
  include Sidekiq::Worker

  STAGGER_OVER = 3.hours
  BATCH_SIZE = 150

  def perform
    BatchDelivery.new(relation: GetInactiveApplicationsFromPastDay.call(single: false), stagger_over: STAGGER_OVER, batch_size: BATCH_SIZE).each do |batch_time, records|
      SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
