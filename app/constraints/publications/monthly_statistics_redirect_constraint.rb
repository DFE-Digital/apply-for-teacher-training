module Publications
  class MonthlyStatisticsRedirectConstraint
    def matches?(_request)
      FeatureFlag.active?(:monthly_statistics_redirected)
    end
  end
end
