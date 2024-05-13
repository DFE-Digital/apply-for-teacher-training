class ProvidersForRecruitmentPerformanceReportQuery
  def self.call(cycle_week:)
    Provider
      .distinct
      .joins(courses: { course_options: :application_choices })
      .where(courses: { recruitment_cycle_year: CycleTimetable.current_year })
      .where('application_choices.sent_to_provider_at < ?', Time.zone.today.beginning_of_week)
      .where.not(id: Publications::ProviderRecruitmentPerformanceReport.select('provider_id id').where(cycle_week:))
      .merge(ApplicationChoice.visible_to_provider)
  end
end
