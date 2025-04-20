class SeedRecruitmentCycleTimetables
  def self.call
    new.call
  end

  def call
    CYCLE_DATES.each do |recruitment_cycle_year, dates|
      RecruitmentCycleTimetable.find_or_create_by(recruitment_cycle_year:).tap do |timetable|
        timetable.update(
          find_opens_at: dates[:find_opens],
          apply_opens_at: dates[:apply_opens],
          apply_deadline_at: dates[:apply_deadline],
          reject_by_default_at: dates[:reject_by_default],
          decline_by_default_at: dates[:find_closes] - 1.day,
          find_closes_at: dates[:find_closes],
        )
      end
    end
  end
end
