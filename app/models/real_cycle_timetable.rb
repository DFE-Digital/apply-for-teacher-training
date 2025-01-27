class RealCycleTimetable < RecruitmentCycleTimetable
  validates :recruitment_cycle_year, uniqueness: { allow_nil: false }
end
