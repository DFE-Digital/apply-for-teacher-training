module DataMigrations
  class SpecifyExportTypeForNotificationExports
    TIMESTAMP = 20210513141008
    MANUAL_RUN = false

    def change
      DataExport
        .where(name: 'Daily export of notifications breakdown')
        .where(export_type: nil)
        .update_all(export_type: :notifications_export)
    end
  end
end
