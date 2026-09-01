module DataMigrations
  class RemoveAPIAndMonthlyStatisticsFeatureFlags
    TIMESTAMP = 20260901143758
    MANUAL_RUN = false

    def change
      Feature.where(name: :api_token_management).destroy_all
      Feature.where(name: :monthly_statistics_redirected).destroy_all
    end
  end
end
