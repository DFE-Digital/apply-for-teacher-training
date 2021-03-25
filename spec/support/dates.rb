MID_CYCLE_DATES = {
  2020 => Time.zone.local(2020, 1, 1, 12, 0, 0),
  2021 => Time.zone.local(2021, 11, 1, 12, 0, 0),
}.freeze

# RSpec.configure do |config|
#   config.around do |example|
#     mid_cycle_date = MID_CYCLE_DATES.fetch(
#       example.metadata[:recruitment_cycle],
#       MID_CYCLE_DATES[RecruitmentCycle.current_year],
#     )
#
#     Timecop.travel(mid_cycle_date) do
#       example.run
#     end
#   end
# end
