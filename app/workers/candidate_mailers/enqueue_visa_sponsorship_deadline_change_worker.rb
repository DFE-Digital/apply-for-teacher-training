module CandidateMailers
  class EnqueueVisaSponsorshipDeadlineChangeWorker
    include Sidekiq::Worker

    def perform(course_id)
      course = Course.open.find_by(id: course_id)
      return if course.nil?

      relation = UnsubmittedApplicationChoicesForCourse.call(course_id)

      stagger_over = if relation.count > 3000
                       (relation.count / 500).minutes
                     else
                       5.minutes
                     end

      BatchDelivery.new(
        relation:,
        batch_size: 120,
        stagger_over:,
      ).each do |batch_time, records|
        SendVisaSponsorshipDeadlineChangeWorker.perform_at(
          batch_time,
          records.pluck(:id),
        )
      end
    end
  end
end
