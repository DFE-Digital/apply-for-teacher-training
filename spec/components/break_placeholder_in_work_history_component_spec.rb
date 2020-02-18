require 'rails_helper'

RSpec.describe BreakPlaceholderInWorkHistoryComponent do
  let(:work_break) { double }

  before do
    allow(work_break).to receive(:length).and_return(3)
    allow(work_break).to receive(:start_date).and_return(Date.new(2020, 1, 1))
    allow(work_break).to receive(:end_date).and_return(Date.new(2020, 5, 1))
  end

  it 'renders the component with a link to explain break' do
    result = render_inline(BreakPlaceholderInWorkHistoryComponent, work_break: work_break)

    expect(result.text).to include('Explain break between January 2020 and May 2020')
  end

  it 'renders the component with a link to add another job' do
    result = render_inline(BreakPlaceholderInWorkHistoryComponent, work_break: work_break)

    expect(result.text).to include('add another job between January 2020 and May 2020')
  end

  context 'when work history break is less than 12 months' do
    it 'renders the component with the break in months' do
      result = render_inline(BreakPlaceholderInWorkHistoryComponent, work_break: work_break)

      expect(result.text).to include('You have a break in your work history in the last 5 years (3 months)')
    end
  end

  context 'when work history break is more than 12 months' do
    before do
      allow(work_break).to receive(:length).and_return(19)
      allow(work_break).to receive(:start_date).and_return(Date.new(2018, 6, 1))
      allow(work_break).to receive(:end_date).and_return(Date.new(2020, 2, 1))
    end

    it 'renders the component with the break in months' do
      result = render_inline(BreakPlaceholderInWorkHistoryComponent, work_break: work_break)

      expect(result.text).to include('You have a break in your work history in the last 5 years (1 year and 7 months)')
    end
  end
end
