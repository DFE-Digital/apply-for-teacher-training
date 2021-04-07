module DataMigrations
  class BackfillExportType
    TIMESTAMP = 20210326113829
    MANUAL_RUN = false

    def change
      data_exports = DataExport.all.where(export_type: nil)

      data_exports.each do |export|
        export_type = export.name == 'Unexplained breaks in work history' ? 'work_history_break' : export.name.parameterize.underscore

        export.update!(export_type: export_type)
      end
    end
  end
end
