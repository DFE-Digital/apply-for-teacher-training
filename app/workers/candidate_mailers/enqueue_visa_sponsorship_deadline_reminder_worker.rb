module CandidateMailers
  class EnqueueVisaSponsorshipDeadlineReminderWorker
    include Sidekiq::Worker

    def perform
      relation = ApplicationChoicesVisaSponsorshipDeadlineReminder.call

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
        SendVisaSponsorshipDeadlineReminderWorker.perform_at(
          batch_time,
          records.pluck(:id),
        )
      end
    end
  end
end
