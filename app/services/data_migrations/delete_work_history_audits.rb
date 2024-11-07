module DataMigrations
  class DeleteWorkHistoryAudits
    TIMESTAMP = 20240917154444
    MANUAL_RUN = false
    BATCH_SIZE = 5000

    def change
      relation.in_batches(of: BATCH_SIZE) do |batch|
        DeleteAuditsWorker.perform_async(batch.ids)
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
