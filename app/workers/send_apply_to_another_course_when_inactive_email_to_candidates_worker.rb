class SendApplyToAnotherCourseWhenInactiveEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    BatchDelivery.new(relation: GetInactiveApplicationsFromPastDay.call).each do |batch_time, records|
      SendApplyToAnotherCourseWhenInactiveEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
