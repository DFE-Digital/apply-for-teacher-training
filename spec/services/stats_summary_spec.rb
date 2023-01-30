require 'rails_helper'

RSpec.describe StatsSummary do
  it 'generates correct stats' do
    create(:candidate)
    create(:application_form)
    create(:application_form, :submitted)
    create(:application_choice, :recruited)
    create(:application_choice, :offered)
    create(:application_choice, :rejected)
    create(:application_choice, :accepted)
    create(:application_choice, :accepted)
    create(:application_choice, :rejected_by_default)

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

    expect(output).to match('9 candidate signups \\| 3 last cycle')
    expect(output).to match('8 applications begun \\| 3 last cycle')
    expect(output).to match('7 applications submitted \\| 3 last cycle')
    expect(output).to match('3 offers accepted \\| 1 last cycle')
    expect(output).to match('1 candidate recruited \\| 1 last cycle')
    expect(output).to match('4 offers made \\| 3 last cycle')
    expect(output).to match('2 rejections issued')
    expect(output).to match('of which 1 was RBD \\| 2 last cycle')
  end
end
