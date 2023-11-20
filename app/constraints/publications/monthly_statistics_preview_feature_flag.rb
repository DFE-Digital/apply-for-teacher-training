module Publications
  class MonthlyStatisticsPreviewFeatureFlag
    def matches?(_request)
      FeatureFlag.active?(:monthly_statistics_preview)
    end
  end
end
