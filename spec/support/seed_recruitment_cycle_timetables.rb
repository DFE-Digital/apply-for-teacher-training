class SeedRecruitmentCycleTimetables
  def self.call
    new.call
  end

  def call
    file = Rails.root.join('config/initializers/cycle_timetables.csv').read
    csv = CSV.parse(file, headers: true)
    ::SeedTimetablesService.new(csv).call
  end
end
