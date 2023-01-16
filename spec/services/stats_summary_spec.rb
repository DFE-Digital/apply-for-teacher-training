require 'rails_helper'

RSpec.describe StatsSummary do
  it 'generates correct stats' do
    create(:application_form, submitted_at: 1.minute.ago)
    create(:application_choice, :recruited)
    create(:application_choice, :offered)
    create(:application_choice, :rejected)
    create(:application_choice, :accepted, accepted_at: 1.minute.ago)
    create(:application_choice, :accepted, accepted_at: 1.minute.ago)
    create(:application_choice, :rejected_by_default)

    travel_temporarily_to(CycleTimetable.this_day_last_cycle) do
      last_cycle_form = create(:application_form)
      create(:application_choice, :recruited, application_form: last_cycle_form)
      create(:application_choice, :offered, application_form: last_cycle_form)
      create(:application_choice, :rejected, application_form: last_cycle_form)
      create(:application_choice, :rejected)
      create(:application_choice, :offered)
    end

    output = described_class.new.as_slack_message

    expect(output).to match('7 candidate signups \\| 3 last cycle')
    expect(output).to match('7 applications begun \\| 3 last cycle')
    expect(output).to match('1 application submitted \\| 0 last cycle')
    expect(output).to match('2 offers accepted \\| 0 last cycle')
    expect(output).to match('1 candidate recruited \\| 1 last cycle')
    expect(output).to match('4 offers made \\| 3 last cycle')
    expect(output).to match('2 rejections issued')
    expect(output).to match('of which 1 was RBD \\| 2 last cycle')
  end
end
