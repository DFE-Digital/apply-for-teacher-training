require 'rails_helper'

RSpec.describe BreakInWorkHistoryComponent do
  let(:february2019) { Time.zone.local(2019, 2, 1) }
  let(:april2019) { Time.zone.local(2019, 4, 1) }
  let(:work_break) do
    build_stubbed(
      :application_work_history_break,
      start_date: february2019,
      end_date: april2019,
      reason: 'I feel asleep.',
    )
  end

  it 'renders the component with the break in months, reason and dates' do
    result = render_inline(BreakInWorkHistoryComponent, work_break: work_break)

    expect(result.text).to include('Break in work history (1 month)')
    expect(result.text).to include('I feel asleep.')
    expect(result.text).to include('February 2019 - April 2019')
  end

  it 'renders the component with a delete link if editable' do
    result = render_inline(BreakInWorkHistoryComponent, work_break: work_break, editable: true)

    expect(result.text).to include('Delete entry for break between February 2019 and April 2019')
  end

  it 'renders the component without a delete link if editable is false' do
    result = render_inline(BreakInWorkHistoryComponent, work_break: work_break, editable: false)

    expect(result.text).not_to include('Delete entry for break between February 2019 and April 2019')
  end
end
