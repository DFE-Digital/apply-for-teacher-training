module DataMigrations
  class BackfillExportType
    TIMESTAMP = 20210326113829
    MANUAL_RUN = false

    def change
      data_exports = DataExport.all.where(export_type: nil)

      data_exports.each do |export|
        export.update!(export_type: export.name.parameterize.underscore)
      end
    end
  end
end
