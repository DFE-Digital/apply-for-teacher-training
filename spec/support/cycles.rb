require 'support/test_helpers/cycle_timetable_helper'

RSpec.configure do |config|
  config.include CycleTimetableHelper

  config.before(mid_cycle: true) do
    set_time(mid_cycle)
  end

  config.before(type: :feature) do |example|
    set_time(mid_cycle) unless example.metadata[:mid_cycle] == false
  end
end
