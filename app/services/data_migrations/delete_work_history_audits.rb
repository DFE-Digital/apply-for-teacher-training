module DataMigrations
  class DeleteWorkHistoryAudits
    TIMESTAMP = 20240917154444
    MANUAL_RUN = true
    BATCH_SIZE = 1500

    def change
      time_now = Time.zone.now
      counter = 1

      relation.in_batches(of: BATCH_SIZE) do |batch|
        next_batch_time = time_now + (counter * 5).seconds
        DeleteAuditsWorker.perform_at(next_batch_time, batch.ids)
        counter += 1
      end
    end

    def relation
      Audited::Audit
        .where('created_at >= ? and created_at <= ?', DateTime.new(2024, 9, 3, 11), DateTime.new(2024, 9, 3, 20))
        .where(user_type: nil, user_id: nil)
        .where(action: :create)
        .where(username: '(Automated process)')
        .where(associated_type: 'ApplicationChoice')
        .where(auditable_type: %w[ApplicationExperience ApplicationWorkHistoryBreak])
        .order(id: :asc)
    end
  end
end
