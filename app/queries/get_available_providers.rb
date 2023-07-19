class GetAvailableProviders
  def self.call
    Provider
      .joins(:courses)
      .where(courses: { recruitment_cycle_year: RecruitmentCycle.current_year, exposed_in_find: true })
      .order(:name)
      .distinct
  end
end
