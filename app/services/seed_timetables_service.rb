class SeedTimetablesService
  attr_reader :timetable_data

  def self.seed_from_csv
    file = Rails.root.join('config/initializers/cycle_timetables.csv').read
    csv = CSV.parse(file, headers: true)
    new(csv).call
  end

  def initialize(timetable_data)
    @timetable_data = timetable_data
  end

  def call
    timetable_data.each do |timetable|
      RecruitmentCycleTimetable.find_or_create_by(recruitment_cycle_year: timetable['recruitment_cycle_year']).tap do |t|
        t.update!(
          find_opens_at: timetable['find_opens_at'],
          apply_opens_at: timetable['apply_opens_at'],
          apply_deadline_at: timetable['apply_deadline_at'],
          reject_by_default_at: timetable['reject_by_default_at'],
          decline_by_default_at: timetable['decline_by_default_at'],
          find_closes_at: timetable['find_closes_at'],
          updated_at: timetable['updated_at'],
        )
      end
    end
  end

private

  def parse_holiday_range(holiday_range)
    return nil if holiday_range.nil?

    holiday_range = JSON.parse(holiday_range)
    holiday_range.first.to_date...holiday_range.last.to_date
  end
end
