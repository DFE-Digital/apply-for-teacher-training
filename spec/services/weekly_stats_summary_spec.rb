require 'rails_helper'

RSpec.describe WeeklyStatsSummary do
  it 'posts the correct stats', time: mid_cycle(2023) do
    create(:application_choice, :recruited, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :offered, application_form: create(:application_form, first_nationality: 'Vatican citizen'))
    create(:application_choice, :rejected, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :rejected, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :accepted, application_form: create(:application_form, first_nationality: 'Vatican citizen'))
    create(:application_choice, :accepted, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :rejected_by_default, application_form: create(:application_form, first_nationality: 'Vatican citizen'))
    create(:application_choice, :inactive, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :inactive, application_form: create(:application_form, first_nationality: 'Vatican citizen'))

    travel_temporarily_to(RecruitmentCycleTimetable.this_day_last_cycle) do
      last_cycle_international_form = create(:application_form, :submitted, first_nationality: 'Vatican citizen')
      last_cycle_domestic_form = create(:application_form, :submitted)
      create(:application_choice, :recruited, application_form: last_cycle_domestic_form)
      create(:application_choice, :offered, application_form: last_cycle_international_form)
      create(:application_choice, :rejected, application_form: last_cycle_domestic_form)
      create(:application_choice, :rejected)
    end

    advance_time_by(1.hour)

    output = described_class.new.as_slack_message

    expect(output).to match('9 total candidate signups \\| This point last cycle we had 3')
    expect(output).to match('5 total applications submitted \\| This point last cycle we had 3')
    expect(output).to match('1 total candidate recruited \\| This point last cycle we had 1')
    expect(output).to match('2 total offers made \\| This point last cycle we had 1')
    expect(output).to match('2 total offers accepted \\| This point last cycle we had 1')
    expect(output).to match('2 total rejections issued \\| This point last cycle we had 2')
    expect(output).to match('1 application turned to inactive')

    expect(output).to match('4 total applications submitted \\| This point last cycle we had 1')
    expect(output).to match('0 total candidates recruited \\| This point last cycle we had 0')
    expect(output).to match('2 total offers made \\| This point last cycle we had 1')
    expect(output).to match('1 total offer accepted \\| This point last cycle we had 0')
    expect(output).to match('2 total rejections issued \\| This point last cycle we had 2')
    expect(output).to match('1 application turned to inactive')
  end
end
