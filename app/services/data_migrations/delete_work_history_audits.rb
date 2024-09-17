module DataMigrations
  class DeleteWorkHistoryAudits
    TIMESTAMP = 20240917154444
    MANUAL_RUN = true

    BATCH_SIZE = 5000

    def change
      BatchDelivery.new(relation:, stagger_over: 24.hours, batch_size: BATCH_SIZE).each do |next_batch_time, audits|
        DeleteWorkHistoryAuditsWorker.perform_at(next_batch_time, audits.pluck(:id))
      end
    end

    def relation
      Audited::Audit
        .where('created_at > ? and created_at < ?', DateTime.new(2024, 9, 3, 11), DateTime.new(2024, 9, 3, 20))
        .where(user_type: nil, user_id: nil)
    end
  end
end
