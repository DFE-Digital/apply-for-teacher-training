require 'rails_helper'

RSpec.describe WeeklyStatsSummary do
  include CycleTimetableHelper

  it 'posts the correct stats', time: mid_cycle(2023) do
    create(:candidate)
    create(:application_form)
    create(:application_form, :submitted)
    create(:application_choice, :recruited)
    create(:application_choice, :offered)
    create(:application_choice, :rejected)
    create(:application_choice, :accepted)
    create(:application_choice, :accepted)
    create(:application_choice, :rejected_by_default)
    create(:application_choice, :offered, application_form: create(:application_form, :submitted, phase: 'apply_2'))

    travel_temporarily_to(CycleTimetable.this_day_last_cycle) do
      last_cycle_form = create(:application_form, :submitted)
      create(:application_choice, :recruited, application_form: last_cycle_form)
      create(:application_choice, :offered, application_form: last_cycle_form)
      create(:application_choice, :rejected, application_form: last_cycle_form)
      create(:application_choice, :rejected)
      create(:application_choice, :offered)
    end

    advance_time_by(1.hour)

    output = described_class.new.as_slack_message

    expect(output).to match('10 total candidate signups \\| This point last cycle we had 3')
    expect(output).to match('8 total initial applications begun \\| This point last cycle we had 3')
    expect(output).to match('1 total Apply again application begun \\| This point last cycle we had 0')
    expect(output).to match('8 total applications submitted \\| This point last cycle we had 3')
    expect(output).to match('1 total candidate recruited \\| This point last cycle we had 1')
    expect(output).to match('5 total offers made \\| This point last cycle we had 3')
    expect(output).to match('3 total offers accepted \\| This point last cycle we had 1')
    expect(output).to match('2 total rejections issued')
    expect(output).to match('of which 1 was RBD \\| This point last cycle we had 2')
  end
end
