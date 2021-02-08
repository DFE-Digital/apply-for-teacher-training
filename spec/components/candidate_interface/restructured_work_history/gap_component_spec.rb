require 'rails_helper'

RSpec.describe CandidateInterface::RestructuredWorkHistory::GapComponent do
  let(:break_period) { double }

  before do
    allow(break_period).to receive(:length).and_return(3)
    allow(break_period).to receive(:start_date).and_return(Date.new(2020, 1, 1))
    allow(break_period).to receive(:end_date).and_return(Date.new(2020, 5, 1))
  end

  it 'renders the component with a link to explain break' do
    result = render_inline(CandidateInterface::RestructuredWorkHistory::GapComponent.new(break_period: break_period))

    expect(result.css('a').last.text).to eq('add a reason for this break')
  end

  it 'renders the component with a link to add another job' do
    result = render_inline(CandidateInterface::RestructuredWorkHistory::GapComponent.new(break_period: break_period))

    expect(result.css('a').first.text).to eq('Add another job')
  end

  it 'renders the component with the break length' do
    result = render_inline(CandidateInterface::RestructuredWorkHistory::GapComponent.new(break_period: break_period))

    expect(result.text).to include('You have a break in your work history (3 months)')
  end
end
