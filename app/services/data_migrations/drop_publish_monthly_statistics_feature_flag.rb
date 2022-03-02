module DataMigrations
  class DropPublishMonthlyStatisticsFeatureFlag
    TIMESTAMP = 20220302134920
    MANUAL_RUN = false

    def change
      Feature.where(name: :publish_monthly_statistics).first&.destroy
    end
  end
end
