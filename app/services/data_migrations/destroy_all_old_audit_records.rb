module DataMigrations
  class DestroyAllOldAuditRecords
    TIMESTAMP = 20241031115946
    MANUAL_RUN = true

    def change
      timestamp = Time.zone.local(2022, 10, 4)

      Audited::Audit.where('created_at < ?', timestamp)
                    .in_batches(of: 10_000)
                    .delete_all
    end
  end
end
