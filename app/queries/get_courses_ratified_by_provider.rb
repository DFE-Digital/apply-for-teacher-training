class GetCoursesRatifiedByProvider
  DEFAULT_RECRUITMENT_CYCLE_YEAR = RecruitmentCycle.current_year

  def self.call(provider:, recruitment_cycle_year: DEFAULT_RECRUITMENT_CYCLE_YEAR)
    provider.accredited_courses
      .where(recruitment_cycle_year: recruitment_cycle_year)
      .where.not(provider: provider)
  end
end
