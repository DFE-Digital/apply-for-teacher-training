module Publications
  class MonthlyStatisticsConstraint
    def matches?(_request)
      FeatureFlag.inactive?(:monthly_statistics_redirected)
    end
  end
end
