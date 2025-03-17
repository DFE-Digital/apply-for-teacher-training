class GetDeferredApplicationChoicesForCurrentCycle
  def self.call
    ApplicationChoice
      .joins(:course)
      .where(status: :offer_deferred)
      .where('courses.recruitment_cycle_year': RecruitmentCycleTimetable.previous_year)
  end
end
