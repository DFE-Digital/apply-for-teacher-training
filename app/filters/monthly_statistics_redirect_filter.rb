class MonthlyStatisticsRedirectFilter
  def self.before(controller)
    redirect_to_temporarily_unavailable(controller) if redirect_required?(controller)
  end

  def self.redirect_required?(controller)
    year = controller.params[:year]

    (feature_active? && year.present? && year.to_i == RecruitmentCycleTimetable.current_year) ||
      (feature_active? && year.blank?)
  end

  def self.feature_active?
    FeatureFlag.active?(:monthly_statistics_redirected)
  end

  def self.redirect_to_temporarily_unavailable(controller)
    controller.redirect_to controller.publications_monthly_statistics_temporarily_unavailable_path
  end
end
