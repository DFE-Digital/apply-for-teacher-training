class GetDeferredApplicationChoicesForCurrentCycle
  def self.call
    ApplicationChoice
      .joins(:course)
      .where(status: :offer_deferred)
      .where('courses.recruitment_cycle_year': RecruitmentCycle.previous_year)
  end
end
