MID_CYCLE_DATE = Time.zone.local(RecruitmentCycle.current_year, 1, 1, 12, 0, 0)

RSpec.configure do |config|
  config.around do |example|
    Timecop.travel(MID_CYCLE_DATE) do
      example.run
    end
  end
end
