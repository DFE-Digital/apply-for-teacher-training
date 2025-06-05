require 'rails_helper'

RSpec.describe StatsSummary do
  it 'generates correct stats' do
    create(:candidate)
    create(:application_choice, :recruited, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :offered, application_form: create(:application_form, first_nationality: 'Vatican citizen'))
    create(:application_choice, :rejected, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :rejected, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :accepted, application_form: create(:application_form, first_nationality: 'Vatican citizen'))
    create(:application_choice, :accepted, application_form: create(:application_form, :minimum_info))
    create(:application_choice, :rejected_by_default, application_form: create(:application_form, first_nationality: 'Vatican citizen'))
    inactive_domestic_choice = create(:application_choice, :inactive, application_form: create(:application_form, :minimum_info))
    inactive_international_choice = create(:application_choice, :inactive, application_form: create(:application_form, first_nationality: 'Vatican citizen'))

    create_list(:pool_invite, 2, :sent_to_candidate, candidate: inactive_domestic_choice.candidate)
    create_list(:pool_invite, 1, :sent_to_candidate, candidate: inactive_international_choice.candidate)

    travel_temporarily_to(this_day_last_cycle) do
      last_cycle_international_form = create(:application_form, :submitted, first_nationality: 'Vatican citizen')
      last_cycle_domestic_form = create(:application_form, :submitted)
      create(:application_choice, :recruited, application_form: last_cycle_domestic_form)
      create(:application_choice, :offered, application_form: last_cycle_international_form)
      create(:application_choice, :rejected, application_form: last_cycle_domestic_form)
      create(:application_choice, :rejected)
      create(:application_choice, :offered)

      create_list(:pool_invite, 3, :sent_to_candidate, candidate: last_cycle_international_form.candidate)
      create_list(:pool_invite, 2, :sent_to_candidate, candidate: last_cycle_domestic_form.candidate)
    end

    advance_time_by(1.hour)

    output = described_class.new.as_slack_message

    expect(output).to match('10 candidate signups \\| 4 last cycle')

    expect(output).to match('5 applications submitted \\| 4 last cycle')
    expect(output).to match('2 offers made \\| 2 last cycle')
    expect(output).to match('2 offers accepted \\| 1 last cycle')
    expect(output).to match('2 rejections issued \\| 2 last cycle')
    expect(output).to match('1 application turned to inactive')
    expect(output).to match('1 candidate recruited \\| 1 last cycle')
    expect(output).to match('2 invites sent \\| 2 last cycle')

    expect(output).to match('4 applications submitted \\| 1 last cycle')
    expect(output).to match('2 offers made \\| 1 last cycle')
    expect(output).to match('1 offer accepted \\| 0 last cycle')
    expect(output).to match('1 rejection issued \\| 0 last cycle')
    expect(output).to match('1 application turned to inactive')
    expect(output).to match('0 candidates recruited \\| 0 last cycle')
    expect(output).to match('1 invite sent \\| 3 last cycle')
  end
end
