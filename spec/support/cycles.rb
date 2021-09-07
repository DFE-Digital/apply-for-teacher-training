require 'support/test_helpers/cycle_timetable_helper'

RSpec.configure do |config|
  config.include CycleTimetableHelper

  config.around mid_cycle: true do |example|
    Timecop.travel(mid_cycle) do
      example.run
    end
  end

  config.around(type: :feature) do |example|
    if example.metadata[:mid_cycle] == false
      example.run
    else
      Timecop.travel(mid_cycle) do
        example.run
      end
    end
  end
end
