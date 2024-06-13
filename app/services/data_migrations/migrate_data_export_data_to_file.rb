module DataMigrations
  class MigrateDataExportDataToFile
    TIMESTAMP = 20240528140244
    MANUAL_RUN = true

    def change
      BatchDelivery.new(relation: DataExport.all, stagger_over: 4.hours, batch_size: 10).each do |next_batch_time, data_exports|
        data_exports.each do |data_export|
          DataExportFileMigrationWorker.perform_at(next_batch_time, data_export.id)
        end
      end
    end
  end
end
