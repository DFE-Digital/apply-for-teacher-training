RSpec.configure do |config|
  config.before(mid_cycle: true) do
    set_time(mid_cycle)
  end

  config.before(type: :feature) do |example|
    set_time(mid_cycle) unless example.metadata[:mid_cycle] == false
  end

  config.before do
    seed_timetables if RecruitmentCycleTimetable.all.empty?
  end
end
