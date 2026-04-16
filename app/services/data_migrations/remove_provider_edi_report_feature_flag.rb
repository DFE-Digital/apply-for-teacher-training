module DataMigrations
  class RemoveProviderEdiReportFeatureFlag
    TIMESTAMP = 20260416154158
    MANUAL_RUN = false

    def change
      Feature.find_by(name: :provider_edi_report)&.destroy
    end
  end
end
