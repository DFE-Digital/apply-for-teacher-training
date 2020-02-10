require 'rails_helper'

RSpec.describe BreakInWorkHistoryComponent do
  let(:work_break) { double }

  before do
    allow(work_break).to receive(:length).and_return(3)
    allow(work_break).to receive(:start_date).and_return(Date.new(2020, 1, 1))
    allow(work_break).to receive(:end_date).and_return(Date.new(2020, 5, 1))
  end

  it 'renders the component with the break in months' do
    result = render_inline(BreakInWorkHistoryComponent, work_break: work_break)

    expect(result.text).to include('You have a break in your work history (3 months)')
  end

  it 'renders the component with a link to add another job' do
    result = render_inline(BreakInWorkHistoryComponent, work_break: work_break)

    expect(result.text).to include('Add another job')
  end
end
