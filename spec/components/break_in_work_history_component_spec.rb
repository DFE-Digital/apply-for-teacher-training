require 'rails_helper'

RSpec.describe BreakInWorkHistoryComponent do
  it 'renders the component with the break in months' do
    work_break = double
    allow(work_break).to receive(:length).and_return(3)

    result = render_inline(BreakInWorkHistoryComponent, work_break: work_break)

    expect(result.text).to include('You have a break in your work history (3 months)')
  end
end
