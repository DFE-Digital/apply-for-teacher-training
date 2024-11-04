module DataMigrations
  class DeleteAllOldAudits
    TIMESTAMP = 20241031115946
    MANUAL_RUN = true

    def change

      DeleteAllOldAuditsInBatches.perform_async
    end
  end
end
