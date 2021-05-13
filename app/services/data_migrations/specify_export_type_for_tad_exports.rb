module DataMigrations
  class SpecifyExportTypeForTADExports
    TIMESTAMP = 20210513141008
    MANUAL_RUN = false

    def change
      DataExport
        .where(name: 'Daily export of applications for TAD')
        .where(export_type: nil)
        .update_all(export_type: :tad_applications)
    end
  end
end
