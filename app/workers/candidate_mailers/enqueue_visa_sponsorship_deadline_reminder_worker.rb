module CandidateMailers
  class EnqueueVisaSponsorshipDeadlineReminderWorker < ApplicationJob
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
        SendVisaSponsorshipDeadlineReminderWorker
          .set(wait_until: batch_time)
          .perform_later(records.pluck(:id))
      end
    end
  end
end
