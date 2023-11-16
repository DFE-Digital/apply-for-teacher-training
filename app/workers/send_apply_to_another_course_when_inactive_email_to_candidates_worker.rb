class SendApplyToAnotherCourseWhenInactiveEmailToCandidatesWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform
    BatchDelivery.new(relation: GetInactiveApplicationsFromPastDay.call, batch_size: BATCH_SIZE).each do |batch_time, records|
      SendApplyToAnotherCourseWhenInactiveEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
