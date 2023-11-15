class SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesWorker
  include Sidekiq::Worker

  def perform
    BatchDelivery.new(relation: GetInactiveApplicationsFromPastDay.call(single: false)).each do |batch_time, records|
      SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end
end
