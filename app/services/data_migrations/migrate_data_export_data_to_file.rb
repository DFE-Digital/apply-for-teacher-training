module DataMigrations
  class MigrateDataExportDataToFile
    TIMESTAMP = 20240528140244
    MANUAL_RUN = true

    def change
      DataExport.find_each do |data_export|
        data_export.file.attach(io: CSV.new(data_export.data).to_io, filename: data_export.filename)
      end
    end
  end
end
